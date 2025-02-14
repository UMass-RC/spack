# Copyright 2013-2022 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)
"""Classes and functions to manage providers of virtual dependencies"""
import itertools

import six

import spack.error
import spack.util.spack_json as sjson


def _cross_provider_maps(lmap, rmap):
    """Return a dictionary that combines constraint requests from both input.

    Args:
        lmap: main provider map
        rmap: provider map with additional constraints
    """
    # TODO: this is pretty darned nasty, and inefficient, but there
    # TODO: are not that many vdeps in most specs.
    result = {}
    for lspec, rspec in itertools.product(lmap, rmap):
        try:
            constrained = lspec.constrained(rspec)
        except spack.error.UnsatisfiableSpecError:
            continue

        # lp and rp are left and right provider specs.
        for lp_spec, rp_spec in itertools.product(lmap[lspec], rmap[rspec]):
            if lp_spec.name == rp_spec.name:
                try:
                    const = lp_spec.constrained(rp_spec, deps=False)
                    result.setdefault(constrained, set()).add(const)
                except spack.error.UnsatisfiableSpecError:
                    continue
    return result


class _IndexBase(object):
    #: This is a dict of dicts used for finding providers of particular
    #: virtual dependencies. The dict of dicts looks like:
    #:
    #:    { vpkg name :
    #:        { full vpkg spec : set(packages providing spec) } }
    #:
    #: Callers can use this to first find which packages provide a vpkg,
    #: then find a matching full spec.  e.g., in this scenario:
    #:
    #:    { 'mpi' :
    #:        { mpi@:1.1 : set([mpich]),
    #:          mpi@:2.3 : set([mpich2@1.9:]) } }
    #:
    #: Calling providers_for(spec) will find specs that provide a
    #: matching implementation of MPI. Derived class need to construct
    #: this attribute according to the semantics above.
    providers = None

    def providers_for(self, virtual_spec):
        """Return a list of specs of all packages that provide virtual
        packages with the supplied spec.

        Args:
            virtual_spec: virtual spec to be provided
        """
        result = set()
        # Allow string names to be passed as input, as well as specs
        if isinstance(virtual_spec, six.string_types):
            virtual_spec = spack.spec.Spec(virtual_spec)

        # Add all the providers that satisfy the vpkg spec.
        if virtual_spec.name in self.providers:
            for p_spec, spec_set in self.providers[virtual_spec.name].items():
                if p_spec.satisfies(virtual_spec, deps=False):
                    result.update(spec_set)

        # Return providers in order. Defensively copy.
        return sorted(s.copy() for s in result)

    def __contains__(self, name):
        return name in self.providers

    def satisfies(self, other):
        """Determine if the providers of virtual specs are compatible.

        Args:
            other: another provider index

        Returns:
            True if the providers are compatible, False otherwise.
        """
        common = set(self.providers) & set(other.providers)
        if not common:
            return True

        # This ensures that some provider in other COULD satisfy the
        # vpkg constraints on self.
        result = {}
        for name in common:
            crossed = _cross_provider_maps(self.providers[name], other.providers[name])
            if crossed:
                result[name] = crossed

        return all(c in result for c in common)

    def __eq__(self, other):
        return self.providers == other.providers

    def _transform(self, transform_fun, out_mapping_type=dict):
        """Transform this provider index dictionary and return it.

        Args:
            transform_fun: transform_fun takes a (vpkg, pset) mapping and runs
                it on each pair in nested dicts.
            out_mapping_type: type to be used internally on the
                transformed (vpkg, pset)

        Returns:
            Transformed mapping
        """
        return _transform(self.providers, transform_fun, out_mapping_type)

    def __str__(self):
        return str(self.providers)

    def __repr__(self):
        return repr(self.providers)


class ProviderIndex(_IndexBase):
    def __init__(self, repository, specs=None, restrict=False):
        """Provider index based on a single mapping of providers.

        Args:
            specs (list of specs): if provided, will call update on each
                single spec to initialize this provider index.

            restrict: "restricts" values to the verbatim input specs; do not
                pre-apply package's constraints.

        TODO: rename this.  It is intended to keep things as broad
        TODO: as possible without overly restricting results, so it is
        TODO: not the best name.
        """
        self.repository = repository
        self.restrict = restrict
        self.providers = {}

        specs = specs or []
        for spec in specs:
            if not isinstance(spec, spack.spec.Spec):
                spec = spack.spec.Spec(spec)

            if self.repository.is_virtual_safe(spec.name):
                continue

            self.update(spec)

    def update(self, spec):
        """Update the provider index with additional virtual specs.

        Args:
            spec: spec potentially providing additional virtual specs
        """
        if not isinstance(spec, spack.spec.Spec):
            spec = spack.spec.Spec(spec)

        if not spec.name:
            # Empty specs do not have a package
            return

        msg = "cannot update an index passing the virtual spec '{}'".format(spec.name)
        assert not self.repository.is_virtual_safe(spec.name), msg

        pkg_provided = self.repository.get_pkg_class(spec.name).provided
        for provided_spec, provider_specs in six.iteritems(pkg_provided):
            for provider_spec_readonly in provider_specs:
                # TODO: fix this comment.
                # We want satisfaction other than flags
                provider_spec = provider_spec_readonly.copy()
                provider_spec.compiler_flags = spec.compiler_flags.copy()

                if spec.satisfies(provider_spec, deps=False):
                    provided_name = provided_spec.name

                    provider_map = self.providers.setdefault(provided_name, {})
                    if provided_spec not in provider_map:
                        provider_map[provided_spec] = set()

                    if self.restrict:
                        provider_set = provider_map[provided_spec]

                        # If this package existed in the index before,
                        # need to take the old versions out, as they're
                        # now more constrained.
                        old = set([s for s in provider_set if s.name == spec.name])
                        provider_set.difference_update(old)

                        # Now add the new version.
                        provider_set.add(spec)

                    else:
                        # Before putting the spec in the map, constrain
                        # it so that it provides what was asked for.
                        constrained = spec.copy()
                        constrained.constrain(provider_spec)
                        provider_map[provided_spec].add(constrained)

    def to_json(self, stream=None):
        """Dump a JSON representation of this object.

        Args:
            stream: stream where to dump
        """
        provider_list = self._transform(
            lambda vpkg, pset: [vpkg.to_node_dict(), [p.to_node_dict() for p in pset]], list
        )

        sjson.dump({"provider_index": {"providers": provider_list}}, stream)

    def merge(self, other):
        """Merge another provider index into this one.

        Args:
            other (ProviderIndex): provider index to be merged
        """
        other = other.copy()  # defensive copy.

        for pkg in other.providers:
            if pkg not in self.providers:
                self.providers[pkg] = other.providers[pkg]
                continue

            spdict, opdict = self.providers[pkg], other.providers[pkg]
            for provided_spec in opdict:
                if provided_spec not in spdict:
                    spdict[provided_spec] = opdict[provided_spec]
                    continue

                spdict[provided_spec] = spdict[provided_spec].union(opdict[provided_spec])

    def remove_provider(self, pkg_name):
        """Remove a provider from the ProviderIndex."""
        empty_pkg_dict = []
        for pkg, pkg_dict in self.providers.items():
            empty_pset = []
            for provided, pset in pkg_dict.items():
                same_name = set(p for p in pset if p.fullname == pkg_name)
                pset.difference_update(same_name)

                if not pset:
                    empty_pset.append(provided)

            for provided in empty_pset:
                del pkg_dict[provided]

            if not pkg_dict:
                empty_pkg_dict.append(pkg)

        for pkg in empty_pkg_dict:
            del self.providers[pkg]

    def copy(self):
        """Return a deep copy of this index."""
        clone = ProviderIndex(repository=self.repository)
        clone.providers = self._transform(lambda vpkg, pset: (vpkg, set((p.copy() for p in pset))))
        return clone

    @staticmethod
    def from_json(stream, repository):
        """Construct a provider index from its JSON representation.

        Args:
            stream: stream where to read from the JSON data
        """
        data = sjson.load(stream)

        if not isinstance(data, dict):
            raise ProviderIndexError("JSON ProviderIndex data was not a dict.")

        if "provider_index" not in data:
            raise ProviderIndexError("YAML ProviderIndex does not start with 'provider_index'")

        index = ProviderIndex(repository=repository)
        providers = data["provider_index"]["providers"]
        index.providers = _transform(
            providers,
            lambda vpkg, plist: (
                spack.spec.Spec.from_node_dict(vpkg),
                set(spack.spec.Spec.from_node_dict(p) for p in plist),
            ),
        )
        return index


def _transform(providers, transform_fun, out_mapping_type=dict):
    """Syntactic sugar for transforming a providers dict.

    Args:
        providers: provider dictionary
        transform_fun: transform_fun takes a (vpkg, pset) mapping and runs
            it on each pair in nested dicts.
        out_mapping_type: type to be used internally on the
            transformed (vpkg, pset)

    Returns:
        Transformed mapping
    """

    def mapiter(mappings):
        if isinstance(mappings, dict):
            return six.iteritems(mappings)
        else:
            return iter(mappings)

    return dict(
        (name, out_mapping_type([transform_fun(vpkg, pset) for vpkg, pset in mapiter(mappings)]))
        for name, mappings in providers.items()
    )


class ProviderIndexError(spack.error.SpackError):
    """Raised when there is a problem with a ProviderIndex."""
