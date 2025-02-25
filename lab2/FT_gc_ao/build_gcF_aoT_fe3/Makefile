#=========================================================================
# Makefile
#=========================================================================
# Generator : /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/backends/make_backend.py

SHELL=/usr/bin/env bash -euo pipefail

# $1 -- $dst
# $2 -- $src
# $3 -- $stamp

define cpdir
	rm -rf ./$1
	cp -aL $2 $1 || true
	chmod -R +w $1
	touch $3
endef

# $1 -- $dst
# $2 -- $src
# $3 -- $stamp

define cpdir-and-parameterize
	rm -rf ./$1
	cp -aL $2 $1 || true
	chmod -R +w $1
	cp .mflowgen/$1/configure.yml $1
	touch $3
endef

# $1 -- $dst
# $2 -- $src
# $3 -- $stamp

define mkdir-and-symlink
	rm -rf ./$1
	mkdir -p $1
	cd $1 && ln -sf ../$2/* . && cd ..
	rm $1/configure.yml && cp .mflowgen/$1/configure.yml $1
	touch $3
endef

# $1 -- $dst_dir
# $2 -- $dst
# $3 -- $src
# $4 -- $stamp

define symlink
	mkdir -p $1
	cd $1 && ln -sf $3 $2 && touch $4
endef

# $1 -- $stamp

define stamp
	touch $1
endef

define make-subgraph-dir
       mkdir -p $1
       chmod -R +w $1
       cd $1 && mflowgen run --subgraph --design $2
       touch $3
endef

# Default

default: arc_ram_lib constraints custom_dc_scripts info rtl skywater-130nm synopsys-dc-synthesis

# ------------------------------------------------------------------------
# arc_ram_lib
# ------------------------------------------------------------------------

# build dir

ifeq ("$(wildcard 0-arc_ram_lib/.prebuilt)","")
0-arc_ram_lib/.stamp:
	$(call cpdir-and-parameterize,0-arc_ram_lib,../../design/arc_ram_lib,0-arc_ram_lib/.stamp)
endif

# collect inputs

# execute

ifeq ("$(wildcard 0-arc_ram_lib/.prebuilt)","")

define 0_arc_ram_lib_commands_rule
	mkdir -p 0-arc_ram_lib/outputs && set -o pipefail && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t arc_ram_lib && chmod +x .mflowgen/0-arc_ram_lib/mflowgen-run && cp -f .mflowgen/0-arc_ram_lib/mflowgen-run 0-arc_ram_lib && if [[ -e .mflowgen/0-arc_ram_lib/mflowgen-debug ]]; then chmod +x .mflowgen/0-arc_ram_lib/mflowgen-debug && cp -f .mflowgen/0-arc_ram_lib/mflowgen-debug 0-arc_ram_lib; fi && if [[ -e .mflowgen/0-arc_ram_lib/mflowgen-check-preconditions.py ]]; then chmod +x .mflowgen/0-arc_ram_lib/mflowgen-check-preconditions.py && cp -f .mflowgen/0-arc_ram_lib/mflowgen-check-preconditions.py 0-arc_ram_lib; fi && if [[ -e .mflowgen/0-arc_ram_lib/mflowgen-check-postconditions.py ]]; then chmod +x .mflowgen/0-arc_ram_lib/mflowgen-check-postconditions.py && cp -f .mflowgen/0-arc_ram_lib/mflowgen-check-postconditions.py 0-arc_ram_lib; fi && cd 0-arc_ram_lib && if [[ -e mflowgen-check-preconditions.py ]]; then ./mflowgen-check-preconditions.py || exit 1; fi && ./mflowgen-run 2>&1 | tee mflowgen-run.log || exit 1 && cd .. && touch -c 0-arc_ram_lib/outputs/*
endef

0-arc_ram_lib/.execstamp: 0-arc_ram_lib/.stamp
	$(call 0_arc_ram_lib_commands_rule)
	touch $@

0-arc_ram_lib/outputs/.execstamp.arc_rams.lib: 0-arc_ram_lib/.execstamp
	touch $@
0-arc_ram_lib/outputs/.execstamp.arc_rams.db: 0-arc_ram_lib/.execstamp
	touch $@

endif

# collect outputs

0-arc_ram_lib/outputs/.stamp.arc_rams.lib: 0-arc_ram_lib/.execstamp 0-arc_ram_lib/outputs/.execstamp.arc_rams.db 0-arc_ram_lib/outputs/.execstamp.arc_rams.lib
	$(call stamp,0-arc_ram_lib/outputs/.stamp.arc_rams.lib)

0-arc_ram_lib/outputs/.stamp.arc_rams.db: 0-arc_ram_lib/.execstamp 0-arc_ram_lib/outputs/.execstamp.arc_rams.db 0-arc_ram_lib/outputs/.execstamp.arc_rams.lib
	$(call stamp,0-arc_ram_lib/outputs/.stamp.arc_rams.db)

# post-conditions

define 0_arc_ram_lib_post_conditions_commands_rule
	cd 0-arc_ram_lib && if [[ -e mflowgen-check-postconditions.py ]]; then ./mflowgen-check-postconditions.py || exit 1; fi && cd ..
endef

0-arc_ram_lib/.postconditions.stamp: 0-arc_ram_lib/.execstamp 0-arc_ram_lib/outputs/.execstamp.arc_rams.db 0-arc_ram_lib/outputs/.execstamp.arc_rams.lib 0-arc_ram_lib/outputs/.stamp.arc_rams.db 0-arc_ram_lib/outputs/.stamp.arc_rams.lib
	$(call 0_arc_ram_lib_post_conditions_commands_rule)
	touch $@

# alias

.PHONY: arc_ram_lib

arc_ram_lib: 0-arc_ram_lib/.execstamp 0-arc_ram_lib/.postconditions.stamp 0-arc_ram_lib/outputs/.execstamp.arc_rams.db 0-arc_ram_lib/outputs/.execstamp.arc_rams.lib 0-arc_ram_lib/outputs/.stamp.arc_rams.db 0-arc_ram_lib/outputs/.stamp.arc_rams.lib

.PHONY: 0

0: 0-arc_ram_lib/.execstamp 0-arc_ram_lib/.postconditions.stamp 0-arc_ram_lib/outputs/.execstamp.arc_rams.db 0-arc_ram_lib/outputs/.execstamp.arc_rams.lib 0-arc_ram_lib/outputs/.stamp.arc_rams.db 0-arc_ram_lib/outputs/.stamp.arc_rams.lib

# debug

# ------------------------------------------------------------------------
# constraints
# ------------------------------------------------------------------------

# build dir

ifeq ("$(wildcard 1-constraints/.prebuilt)","")
1-constraints/.stamp:
	$(call cpdir-and-parameterize,1-constraints,../../design/constraints,1-constraints/.stamp)
endif

# collect inputs

# execute

ifeq ("$(wildcard 1-constraints/.prebuilt)","")

define 1_constraints_commands_rule
	mkdir -p 1-constraints/outputs && set -o pipefail && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t constraints && chmod +x .mflowgen/1-constraints/mflowgen-run && cp -f .mflowgen/1-constraints/mflowgen-run 1-constraints && if [[ -e .mflowgen/1-constraints/mflowgen-debug ]]; then chmod +x .mflowgen/1-constraints/mflowgen-debug && cp -f .mflowgen/1-constraints/mflowgen-debug 1-constraints; fi && if [[ -e .mflowgen/1-constraints/mflowgen-check-preconditions.py ]]; then chmod +x .mflowgen/1-constraints/mflowgen-check-preconditions.py && cp -f .mflowgen/1-constraints/mflowgen-check-preconditions.py 1-constraints; fi && if [[ -e .mflowgen/1-constraints/mflowgen-check-postconditions.py ]]; then chmod +x .mflowgen/1-constraints/mflowgen-check-postconditions.py && cp -f .mflowgen/1-constraints/mflowgen-check-postconditions.py 1-constraints; fi && cd 1-constraints && if [[ -e mflowgen-check-preconditions.py ]]; then ./mflowgen-check-preconditions.py || exit 1; fi && ./mflowgen-run 2>&1 | tee mflowgen-run.log || exit 1 && cd .. && touch -c 1-constraints/outputs/*
endef

1-constraints/.execstamp: 1-constraints/.stamp
	$(call 1_constraints_commands_rule)
	touch $@

1-constraints/outputs/.execstamp.constraints.tcl: 1-constraints/.execstamp
	touch $@

endif

# collect outputs

1-constraints/outputs/.stamp.constraints.tcl: 1-constraints/.execstamp 1-constraints/outputs/.execstamp.constraints.tcl
	$(call stamp,1-constraints/outputs/.stamp.constraints.tcl)

# post-conditions

define 1_constraints_post_conditions_commands_rule
	cd 1-constraints && if [[ -e mflowgen-check-postconditions.py ]]; then ./mflowgen-check-postconditions.py || exit 1; fi && cd ..
endef

1-constraints/.postconditions.stamp: 1-constraints/.execstamp 1-constraints/outputs/.execstamp.constraints.tcl 1-constraints/outputs/.stamp.constraints.tcl
	$(call 1_constraints_post_conditions_commands_rule)
	touch $@

# alias

.PHONY: constraints

constraints: 1-constraints/.execstamp 1-constraints/.postconditions.stamp 1-constraints/outputs/.execstamp.constraints.tcl 1-constraints/outputs/.stamp.constraints.tcl

.PHONY: 1

1: 1-constraints/.execstamp 1-constraints/.postconditions.stamp 1-constraints/outputs/.execstamp.constraints.tcl 1-constraints/outputs/.stamp.constraints.tcl

# debug

# ------------------------------------------------------------------------
# custom_dc_scripts
# ------------------------------------------------------------------------

# build dir

ifeq ("$(wildcard 2-custom_dc_scripts/.prebuilt)","")
2-custom_dc_scripts/.stamp:
	$(call cpdir-and-parameterize,2-custom_dc_scripts,../../design/custom_dc_scripts,2-custom_dc_scripts/.stamp)
endif

# collect inputs

# execute

ifeq ("$(wildcard 2-custom_dc_scripts/.prebuilt)","")

define 2_custom_dc_scripts_commands_rule
	mkdir -p 2-custom_dc_scripts/outputs && set -o pipefail && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t custom_dc_scripts && chmod +x .mflowgen/2-custom_dc_scripts/mflowgen-run && cp -f .mflowgen/2-custom_dc_scripts/mflowgen-run 2-custom_dc_scripts && if [[ -e .mflowgen/2-custom_dc_scripts/mflowgen-debug ]]; then chmod +x .mflowgen/2-custom_dc_scripts/mflowgen-debug && cp -f .mflowgen/2-custom_dc_scripts/mflowgen-debug 2-custom_dc_scripts; fi && if [[ -e .mflowgen/2-custom_dc_scripts/mflowgen-check-preconditions.py ]]; then chmod +x .mflowgen/2-custom_dc_scripts/mflowgen-check-preconditions.py && cp -f .mflowgen/2-custom_dc_scripts/mflowgen-check-preconditions.py 2-custom_dc_scripts; fi && if [[ -e .mflowgen/2-custom_dc_scripts/mflowgen-check-postconditions.py ]]; then chmod +x .mflowgen/2-custom_dc_scripts/mflowgen-check-postconditions.py && cp -f .mflowgen/2-custom_dc_scripts/mflowgen-check-postconditions.py 2-custom_dc_scripts; fi && cd 2-custom_dc_scripts && if [[ -e mflowgen-check-preconditions.py ]]; then ./mflowgen-check-preconditions.py || exit 1; fi && ./mflowgen-run 2>&1 | tee mflowgen-run.log || exit 1 && cd .. && touch -c 2-custom_dc_scripts/outputs/*
endef

2-custom_dc_scripts/.execstamp: 2-custom_dc_scripts/.stamp
	$(call 2_custom_dc_scripts_commands_rule)
	touch $@

2-custom_dc_scripts/outputs/.execstamp.generate-results.tcl: 2-custom_dc_scripts/.execstamp
	touch $@

endif

# collect outputs

2-custom_dc_scripts/outputs/.stamp.generate-results.tcl: 2-custom_dc_scripts/.execstamp 2-custom_dc_scripts/outputs/.execstamp.generate-results.tcl
	$(call stamp,2-custom_dc_scripts/outputs/.stamp.generate-results.tcl)

# post-conditions

define 2_custom_dc_scripts_post_conditions_commands_rule
	cd 2-custom_dc_scripts && if [[ -e mflowgen-check-postconditions.py ]]; then ./mflowgen-check-postconditions.py || exit 1; fi && cd ..
endef

2-custom_dc_scripts/.postconditions.stamp: 2-custom_dc_scripts/.execstamp 2-custom_dc_scripts/outputs/.execstamp.generate-results.tcl 2-custom_dc_scripts/outputs/.stamp.generate-results.tcl
	$(call 2_custom_dc_scripts_post_conditions_commands_rule)
	touch $@

# alias

.PHONY: custom_dc_scripts

custom_dc_scripts: 2-custom_dc_scripts/.execstamp 2-custom_dc_scripts/.postconditions.stamp 2-custom_dc_scripts/outputs/.execstamp.generate-results.tcl 2-custom_dc_scripts/outputs/.stamp.generate-results.tcl

.PHONY: 2

2: 2-custom_dc_scripts/.execstamp 2-custom_dc_scripts/.postconditions.stamp 2-custom_dc_scripts/outputs/.execstamp.generate-results.tcl 2-custom_dc_scripts/outputs/.stamp.generate-results.tcl

# debug

# ------------------------------------------------------------------------
# info
# ------------------------------------------------------------------------

# build dir

ifeq ("$(wildcard 3-info/.prebuilt)","")
3-info/.stamp:
	$(call cpdir-and-parameterize,3-info,../../../ee292a_lab1/mflowgen/steps/info,3-info/.stamp)
endif

# collect inputs

# execute

ifeq ("$(wildcard 3-info/.prebuilt)","")

define 3_info_commands_rule
	mkdir -p 3-info/outputs && set -o pipefail && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t info && chmod +x .mflowgen/3-info/mflowgen-run && cp -f .mflowgen/3-info/mflowgen-run 3-info && if [[ -e .mflowgen/3-info/mflowgen-debug ]]; then chmod +x .mflowgen/3-info/mflowgen-debug && cp -f .mflowgen/3-info/mflowgen-debug 3-info; fi && if [[ -e .mflowgen/3-info/mflowgen-check-preconditions.py ]]; then chmod +x .mflowgen/3-info/mflowgen-check-preconditions.py && cp -f .mflowgen/3-info/mflowgen-check-preconditions.py 3-info; fi && if [[ -e .mflowgen/3-info/mflowgen-check-postconditions.py ]]; then chmod +x .mflowgen/3-info/mflowgen-check-postconditions.py && cp -f .mflowgen/3-info/mflowgen-check-postconditions.py 3-info; fi && cd 3-info && if [[ -e mflowgen-check-preconditions.py ]]; then ./mflowgen-check-preconditions.py || exit 1; fi && ./mflowgen-run 2>&1 | tee mflowgen-run.log || exit 1 && cd .. && touch -c 3-info/outputs/*
endef

3-info/.execstamp: 3-info/.stamp
	$(call 3_info_commands_rule)

3-info/.execstamp.execute-phony: 3-info/.execstamp
	touch $@

endif

# collect outputs

# post-conditions

define 3_info_post_conditions_commands_rule
	cd 3-info && if [[ -e mflowgen-check-postconditions.py ]]; then ./mflowgen-check-postconditions.py || exit 1; fi && cd ..
endef

3-info/.postconditions.stamp: 3-info/.execstamp 3-info/.execstamp.execute-phony
	$(call 3_info_post_conditions_commands_rule)
	touch $@

# alias

.PHONY: info

info: 3-info/.execstamp 3-info/.execstamp.execute-phony 3-info/.postconditions.stamp

.PHONY: 3

3: 3-info/.execstamp 3-info/.execstamp.execute-phony 3-info/.postconditions.stamp

# debug

# ------------------------------------------------------------------------
# rtl
# ------------------------------------------------------------------------

# build dir

ifeq ("$(wildcard 4-rtl/.prebuilt)","")
4-rtl/.stamp:
	$(call cpdir-and-parameterize,4-rtl,../../design/rtl,4-rtl/.stamp)
endif

# collect inputs

# execute

ifeq ("$(wildcard 4-rtl/.prebuilt)","")

define 4_rtl_commands_rule
	mkdir -p 4-rtl/outputs && set -o pipefail && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t rtl && chmod +x .mflowgen/4-rtl/mflowgen-run && cp -f .mflowgen/4-rtl/mflowgen-run 4-rtl && if [[ -e .mflowgen/4-rtl/mflowgen-debug ]]; then chmod +x .mflowgen/4-rtl/mflowgen-debug && cp -f .mflowgen/4-rtl/mflowgen-debug 4-rtl; fi && if [[ -e .mflowgen/4-rtl/mflowgen-check-preconditions.py ]]; then chmod +x .mflowgen/4-rtl/mflowgen-check-preconditions.py && cp -f .mflowgen/4-rtl/mflowgen-check-preconditions.py 4-rtl; fi && if [[ -e .mflowgen/4-rtl/mflowgen-check-postconditions.py ]]; then chmod +x .mflowgen/4-rtl/mflowgen-check-postconditions.py && cp -f .mflowgen/4-rtl/mflowgen-check-postconditions.py 4-rtl; fi && cd 4-rtl && if [[ -e mflowgen-check-preconditions.py ]]; then ./mflowgen-check-preconditions.py || exit 1; fi && ./mflowgen-run 2>&1 | tee mflowgen-run.log || exit 1 && cd .. && touch -c 4-rtl/outputs/*
endef

4-rtl/.execstamp: 4-rtl/.stamp
	$(call 4_rtl_commands_rule)
	touch $@

4-rtl/outputs/.execstamp.design.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.extutil.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.jtag_defs.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.arcutil.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.arcutil_pkg_defines.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.asmutil.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.che_util.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.xdefs.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.uxdefs.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.ext_msb.v: 4-rtl/.execstamp
	touch $@
4-rtl/outputs/.execstamp.arc600constants.v: 4-rtl/.execstamp
	touch $@

endif

# collect outputs

4-rtl/outputs/.stamp.design.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.design.v)

4-rtl/outputs/.stamp.extutil.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.extutil.v)

4-rtl/outputs/.stamp.jtag_defs.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.jtag_defs.v)

4-rtl/outputs/.stamp.arcutil.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.arcutil.v)

4-rtl/outputs/.stamp.arcutil_pkg_defines.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.arcutil_pkg_defines.v)

4-rtl/outputs/.stamp.asmutil.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.asmutil.v)

4-rtl/outputs/.stamp.che_util.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.che_util.v)

4-rtl/outputs/.stamp.xdefs.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.xdefs.v)

4-rtl/outputs/.stamp.uxdefs.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.uxdefs.v)

4-rtl/outputs/.stamp.ext_msb.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.ext_msb.v)

4-rtl/outputs/.stamp.arc600constants.v: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v
	$(call stamp,4-rtl/outputs/.stamp.arc600constants.v)

# post-conditions

define 4_rtl_post_conditions_commands_rule
	cd 4-rtl && if [[ -e mflowgen-check-postconditions.py ]]; then ./mflowgen-check-postconditions.py || exit 1; fi && cd ..
endef

4-rtl/.postconditions.stamp: 4-rtl/.execstamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v 4-rtl/outputs/.stamp.arc600constants.v 4-rtl/outputs/.stamp.arcutil.v 4-rtl/outputs/.stamp.arcutil_pkg_defines.v 4-rtl/outputs/.stamp.asmutil.v 4-rtl/outputs/.stamp.che_util.v 4-rtl/outputs/.stamp.design.v 4-rtl/outputs/.stamp.ext_msb.v 4-rtl/outputs/.stamp.extutil.v 4-rtl/outputs/.stamp.jtag_defs.v 4-rtl/outputs/.stamp.uxdefs.v 4-rtl/outputs/.stamp.xdefs.v
	$(call 4_rtl_post_conditions_commands_rule)
	touch $@

# alias

.PHONY: rtl

rtl: 4-rtl/.execstamp 4-rtl/.postconditions.stamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v 4-rtl/outputs/.stamp.arc600constants.v 4-rtl/outputs/.stamp.arcutil.v 4-rtl/outputs/.stamp.arcutil_pkg_defines.v 4-rtl/outputs/.stamp.asmutil.v 4-rtl/outputs/.stamp.che_util.v 4-rtl/outputs/.stamp.design.v 4-rtl/outputs/.stamp.ext_msb.v 4-rtl/outputs/.stamp.extutil.v 4-rtl/outputs/.stamp.jtag_defs.v 4-rtl/outputs/.stamp.uxdefs.v 4-rtl/outputs/.stamp.xdefs.v

.PHONY: 4

4: 4-rtl/.execstamp 4-rtl/.postconditions.stamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v 4-rtl/outputs/.stamp.arc600constants.v 4-rtl/outputs/.stamp.arcutil.v 4-rtl/outputs/.stamp.arcutil_pkg_defines.v 4-rtl/outputs/.stamp.asmutil.v 4-rtl/outputs/.stamp.che_util.v 4-rtl/outputs/.stamp.design.v 4-rtl/outputs/.stamp.ext_msb.v 4-rtl/outputs/.stamp.extutil.v 4-rtl/outputs/.stamp.jtag_defs.v 4-rtl/outputs/.stamp.uxdefs.v 4-rtl/outputs/.stamp.xdefs.v

# debug

# ------------------------------------------------------------------------
# skywater-130nm
# ------------------------------------------------------------------------

# build dir

ifeq ("$(wildcard 5-skywater-130nm/.prebuilt)","")
5-skywater-130nm/.stamp:
	$(call cpdir-and-parameterize,5-skywater-130nm,../../../../../../../../farmshare/home/classes/ee/292a/skywater-130nm-adk.v2021,5-skywater-130nm/.stamp)
endif

# collect inputs

# execute

ifeq ("$(wildcard 5-skywater-130nm/.prebuilt)","")

define 5_skywater_130nm_commands_rule
	mkdir -p 5-skywater-130nm/outputs && set -o pipefail && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t skywater-130nm && chmod +x .mflowgen/5-skywater-130nm/mflowgen-run && cp -f .mflowgen/5-skywater-130nm/mflowgen-run 5-skywater-130nm && if [[ -e .mflowgen/5-skywater-130nm/mflowgen-debug ]]; then chmod +x .mflowgen/5-skywater-130nm/mflowgen-debug && cp -f .mflowgen/5-skywater-130nm/mflowgen-debug 5-skywater-130nm; fi && if [[ -e .mflowgen/5-skywater-130nm/mflowgen-check-preconditions.py ]]; then chmod +x .mflowgen/5-skywater-130nm/mflowgen-check-preconditions.py && cp -f .mflowgen/5-skywater-130nm/mflowgen-check-preconditions.py 5-skywater-130nm; fi && if [[ -e .mflowgen/5-skywater-130nm/mflowgen-check-postconditions.py ]]; then chmod +x .mflowgen/5-skywater-130nm/mflowgen-check-postconditions.py && cp -f .mflowgen/5-skywater-130nm/mflowgen-check-postconditions.py 5-skywater-130nm; fi && cd 5-skywater-130nm && if [[ -e mflowgen-check-preconditions.py ]]; then ./mflowgen-check-preconditions.py || exit 1; fi && ./mflowgen-run 2>&1 | tee mflowgen-run.log || exit 1 && cd .. && touch -c 5-skywater-130nm/outputs/*
endef

5-skywater-130nm/.execstamp: 5-skywater-130nm/.stamp
	$(call 5_skywater_130nm_commands_rule)
	touch $@

5-skywater-130nm/outputs/.execstamp.adk: 5-skywater-130nm/.execstamp
	touch $@

endif

# collect outputs

5-skywater-130nm/outputs/.stamp.adk: 5-skywater-130nm/.execstamp 5-skywater-130nm/outputs/.execstamp.adk
	$(call stamp,5-skywater-130nm/outputs/.stamp.adk)

# post-conditions

define 5_skywater_130nm_post_conditions_commands_rule
	cd 5-skywater-130nm && if [[ -e mflowgen-check-postconditions.py ]]; then ./mflowgen-check-postconditions.py || exit 1; fi && cd ..
endef

5-skywater-130nm/.postconditions.stamp: 5-skywater-130nm/.execstamp 5-skywater-130nm/outputs/.execstamp.adk 5-skywater-130nm/outputs/.stamp.adk
	$(call 5_skywater_130nm_post_conditions_commands_rule)
	touch $@

# alias

.PHONY: skywater-130nm

skywater-130nm: 5-skywater-130nm/.execstamp 5-skywater-130nm/.postconditions.stamp 5-skywater-130nm/outputs/.execstamp.adk 5-skywater-130nm/outputs/.stamp.adk

.PHONY: 5

5: 5-skywater-130nm/.execstamp 5-skywater-130nm/.postconditions.stamp 5-skywater-130nm/outputs/.execstamp.adk 5-skywater-130nm/outputs/.stamp.adk

# debug

# ------------------------------------------------------------------------
# synopsys-dc-synthesis
# ------------------------------------------------------------------------

# build dir

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/.stamp: 0-arc_ram_lib/.execstamp 0-arc_ram_lib/.postconditions.stamp 0-arc_ram_lib/outputs/.execstamp.arc_rams.db 0-arc_ram_lib/outputs/.execstamp.arc_rams.lib 0-arc_ram_lib/outputs/.stamp.arc_rams.db 0-arc_ram_lib/outputs/.stamp.arc_rams.lib
6-synopsys-dc-synthesis/.stamp: 1-constraints/.execstamp 1-constraints/.postconditions.stamp 1-constraints/outputs/.execstamp.constraints.tcl 1-constraints/outputs/.stamp.constraints.tcl
6-synopsys-dc-synthesis/.stamp: 2-custom_dc_scripts/.execstamp 2-custom_dc_scripts/.postconditions.stamp 2-custom_dc_scripts/outputs/.execstamp.generate-results.tcl 2-custom_dc_scripts/outputs/.stamp.generate-results.tcl
6-synopsys-dc-synthesis/.stamp: 4-rtl/.execstamp 4-rtl/.postconditions.stamp 4-rtl/outputs/.execstamp.arc600constants.v 4-rtl/outputs/.execstamp.arcutil.v 4-rtl/outputs/.execstamp.arcutil_pkg_defines.v 4-rtl/outputs/.execstamp.asmutil.v 4-rtl/outputs/.execstamp.che_util.v 4-rtl/outputs/.execstamp.design.v 4-rtl/outputs/.execstamp.ext_msb.v 4-rtl/outputs/.execstamp.extutil.v 4-rtl/outputs/.execstamp.jtag_defs.v 4-rtl/outputs/.execstamp.uxdefs.v 4-rtl/outputs/.execstamp.xdefs.v 4-rtl/outputs/.stamp.arc600constants.v 4-rtl/outputs/.stamp.arcutil.v 4-rtl/outputs/.stamp.arcutil_pkg_defines.v 4-rtl/outputs/.stamp.asmutil.v 4-rtl/outputs/.stamp.che_util.v 4-rtl/outputs/.stamp.design.v 4-rtl/outputs/.stamp.ext_msb.v 4-rtl/outputs/.stamp.extutil.v 4-rtl/outputs/.stamp.jtag_defs.v 4-rtl/outputs/.stamp.uxdefs.v 4-rtl/outputs/.stamp.xdefs.v
6-synopsys-dc-synthesis/.stamp: 5-skywater-130nm/.execstamp 5-skywater-130nm/.postconditions.stamp 5-skywater-130nm/outputs/.execstamp.adk 5-skywater-130nm/outputs/.stamp.adk
6-synopsys-dc-synthesis/.stamp:
	$(call cpdir-and-parameterize,6-synopsys-dc-synthesis,../../../ee292a_lab1/mflowgen/steps/synopsys-dc-synthesis,6-synopsys-dc-synthesis/.stamp)
endif

# collect inputs

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.adk: 6-synopsys-dc-synthesis/.stamp 5-skywater-130nm/outputs/.stamp.adk
	$(call symlink,6-synopsys-dc-synthesis/inputs,adk,../../5-skywater-130nm/outputs/adk,.stamp.adk)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.arc600constants.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.arc600constants.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,arc600constants.v,../../4-rtl/outputs/arc600constants.v,.stamp.arc600constants.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.arc_rams.db: 6-synopsys-dc-synthesis/.stamp 0-arc_ram_lib/outputs/.stamp.arc_rams.db
	$(call symlink,6-synopsys-dc-synthesis/inputs,arc_rams.db,../../0-arc_ram_lib/outputs/arc_rams.db,.stamp.arc_rams.db)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.arcutil.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.arcutil.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,arcutil.v,../../4-rtl/outputs/arcutil.v,.stamp.arcutil.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.arcutil_pkg_defines.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.arcutil_pkg_defines.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,arcutil_pkg_defines.v,../../4-rtl/outputs/arcutil_pkg_defines.v,.stamp.arcutil_pkg_defines.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.asmutil.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.asmutil.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,asmutil.v,../../4-rtl/outputs/asmutil.v,.stamp.asmutil.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.che_util.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.che_util.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,che_util.v,../../4-rtl/outputs/che_util.v,.stamp.che_util.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.constraints.tcl: 6-synopsys-dc-synthesis/.stamp 1-constraints/outputs/.stamp.constraints.tcl
	$(call symlink,6-synopsys-dc-synthesis/inputs,constraints.tcl,../../1-constraints/outputs/constraints.tcl,.stamp.constraints.tcl)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.design.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.design.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,design.v,../../4-rtl/outputs/design.v,.stamp.design.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.ext_msb.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.ext_msb.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,ext_msb.v,../../4-rtl/outputs/ext_msb.v,.stamp.ext_msb.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.extutil.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.extutil.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,extutil.v,../../4-rtl/outputs/extutil.v,.stamp.extutil.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.generate-results.tcl: 6-synopsys-dc-synthesis/.stamp 2-custom_dc_scripts/outputs/.stamp.generate-results.tcl
	$(call symlink,6-synopsys-dc-synthesis/inputs,generate-results.tcl,../../2-custom_dc_scripts/outputs/generate-results.tcl,.stamp.generate-results.tcl)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.jtag_defs.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.jtag_defs.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,jtag_defs.v,../../4-rtl/outputs/jtag_defs.v,.stamp.jtag_defs.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.uxdefs.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.uxdefs.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,uxdefs.v,../../4-rtl/outputs/uxdefs.v,.stamp.uxdefs.v)
endif

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")
6-synopsys-dc-synthesis/inputs/.stamp.xdefs.v: 6-synopsys-dc-synthesis/.stamp 4-rtl/outputs/.stamp.xdefs.v
	$(call symlink,6-synopsys-dc-synthesis/inputs,xdefs.v,../../4-rtl/outputs/xdefs.v,.stamp.xdefs.v)
endif

# execute

ifeq ("$(wildcard 6-synopsys-dc-synthesis/.prebuilt)","")

define 6_synopsys_dc_synthesis_commands_rule
	mkdir -p 6-synopsys-dc-synthesis/outputs && set -o pipefail && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t synopsys-dc-synthesis && chmod +x .mflowgen/6-synopsys-dc-synthesis/mflowgen-run && cp -f .mflowgen/6-synopsys-dc-synthesis/mflowgen-run 6-synopsys-dc-synthesis && if [[ -e .mflowgen/6-synopsys-dc-synthesis/mflowgen-debug ]]; then chmod +x .mflowgen/6-synopsys-dc-synthesis/mflowgen-debug && cp -f .mflowgen/6-synopsys-dc-synthesis/mflowgen-debug 6-synopsys-dc-synthesis; fi && if [[ -e .mflowgen/6-synopsys-dc-synthesis/mflowgen-check-preconditions.py ]]; then chmod +x .mflowgen/6-synopsys-dc-synthesis/mflowgen-check-preconditions.py && cp -f .mflowgen/6-synopsys-dc-synthesis/mflowgen-check-preconditions.py 6-synopsys-dc-synthesis; fi && if [[ -e .mflowgen/6-synopsys-dc-synthesis/mflowgen-check-postconditions.py ]]; then chmod +x .mflowgen/6-synopsys-dc-synthesis/mflowgen-check-postconditions.py && cp -f .mflowgen/6-synopsys-dc-synthesis/mflowgen-check-postconditions.py 6-synopsys-dc-synthesis; fi && cd 6-synopsys-dc-synthesis && if [[ -e mflowgen-check-preconditions.py ]]; then ./mflowgen-check-preconditions.py || exit 1; fi && ./mflowgen-run 2>&1 | tee mflowgen-run.log || exit 1 && cd .. && touch -c 6-synopsys-dc-synthesis/outputs/*
endef

6-synopsys-dc-synthesis/.execstamp: 6-synopsys-dc-synthesis/.stamp 6-synopsys-dc-synthesis/inputs/.stamp.adk 6-synopsys-dc-synthesis/inputs/.stamp.arc600constants.v 6-synopsys-dc-synthesis/inputs/.stamp.arc_rams.db 6-synopsys-dc-synthesis/inputs/.stamp.arcutil.v 6-synopsys-dc-synthesis/inputs/.stamp.arcutil_pkg_defines.v 6-synopsys-dc-synthesis/inputs/.stamp.asmutil.v 6-synopsys-dc-synthesis/inputs/.stamp.che_util.v 6-synopsys-dc-synthesis/inputs/.stamp.constraints.tcl 6-synopsys-dc-synthesis/inputs/.stamp.design.v 6-synopsys-dc-synthesis/inputs/.stamp.ext_msb.v 6-synopsys-dc-synthesis/inputs/.stamp.extutil.v 6-synopsys-dc-synthesis/inputs/.stamp.generate-results.tcl 6-synopsys-dc-synthesis/inputs/.stamp.jtag_defs.v 6-synopsys-dc-synthesis/inputs/.stamp.uxdefs.v 6-synopsys-dc-synthesis/inputs/.stamp.xdefs.v
	$(call 6_synopsys_dc_synthesis_commands_rule)
	touch $@

6-synopsys-dc-synthesis/outputs/.execstamp.design.v: 6-synopsys-dc-synthesis/.execstamp
	touch $@
6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc: 6-synopsys-dc-synthesis/.execstamp
	touch $@
6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap: 6-synopsys-dc-synthesis/.execstamp
	touch $@
6-synopsys-dc-synthesis/outputs/.execstamp.design.svf: 6-synopsys-dc-synthesis/.execstamp
	touch $@
6-synopsys-dc-synthesis/outputs/.execstamp.design.upf: 6-synopsys-dc-synthesis/.execstamp
	touch $@

endif

# collect outputs

6-synopsys-dc-synthesis/outputs/.stamp.design.v: 6-synopsys-dc-synthesis/.execstamp 6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap 6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc 6-synopsys-dc-synthesis/outputs/.execstamp.design.svf 6-synopsys-dc-synthesis/outputs/.execstamp.design.upf 6-synopsys-dc-synthesis/outputs/.execstamp.design.v
	$(call stamp,6-synopsys-dc-synthesis/outputs/.stamp.design.v)

6-synopsys-dc-synthesis/outputs/.stamp.design.sdc: 6-synopsys-dc-synthesis/.execstamp 6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap 6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc 6-synopsys-dc-synthesis/outputs/.execstamp.design.svf 6-synopsys-dc-synthesis/outputs/.execstamp.design.upf 6-synopsys-dc-synthesis/outputs/.execstamp.design.v
	$(call stamp,6-synopsys-dc-synthesis/outputs/.stamp.design.sdc)

6-synopsys-dc-synthesis/outputs/.stamp.design.namemap: 6-synopsys-dc-synthesis/.execstamp 6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap 6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc 6-synopsys-dc-synthesis/outputs/.execstamp.design.svf 6-synopsys-dc-synthesis/outputs/.execstamp.design.upf 6-synopsys-dc-synthesis/outputs/.execstamp.design.v
	$(call stamp,6-synopsys-dc-synthesis/outputs/.stamp.design.namemap)

6-synopsys-dc-synthesis/outputs/.stamp.design.svf: 6-synopsys-dc-synthesis/.execstamp 6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap 6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc 6-synopsys-dc-synthesis/outputs/.execstamp.design.svf 6-synopsys-dc-synthesis/outputs/.execstamp.design.upf 6-synopsys-dc-synthesis/outputs/.execstamp.design.v
	$(call stamp,6-synopsys-dc-synthesis/outputs/.stamp.design.svf)

6-synopsys-dc-synthesis/outputs/.stamp.design.upf: 6-synopsys-dc-synthesis/.execstamp 6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap 6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc 6-synopsys-dc-synthesis/outputs/.execstamp.design.svf 6-synopsys-dc-synthesis/outputs/.execstamp.design.upf 6-synopsys-dc-synthesis/outputs/.execstamp.design.v
	$(call stamp,6-synopsys-dc-synthesis/outputs/.stamp.design.upf)

# post-conditions

define 6_synopsys_dc_synthesis_post_conditions_commands_rule
	cd 6-synopsys-dc-synthesis && if [[ -e mflowgen-check-postconditions.py ]]; then ./mflowgen-check-postconditions.py || exit 1; fi && cd ..
endef

6-synopsys-dc-synthesis/.postconditions.stamp: 6-synopsys-dc-synthesis/.execstamp 6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap 6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc 6-synopsys-dc-synthesis/outputs/.execstamp.design.svf 6-synopsys-dc-synthesis/outputs/.execstamp.design.upf 6-synopsys-dc-synthesis/outputs/.execstamp.design.v 6-synopsys-dc-synthesis/outputs/.stamp.design.namemap 6-synopsys-dc-synthesis/outputs/.stamp.design.sdc 6-synopsys-dc-synthesis/outputs/.stamp.design.svf 6-synopsys-dc-synthesis/outputs/.stamp.design.upf 6-synopsys-dc-synthesis/outputs/.stamp.design.v
	$(call 6_synopsys_dc_synthesis_post_conditions_commands_rule)
	touch $@

# alias

.PHONY: synopsys-dc-synthesis

synopsys-dc-synthesis: 6-synopsys-dc-synthesis/.execstamp 6-synopsys-dc-synthesis/.postconditions.stamp 6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap 6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc 6-synopsys-dc-synthesis/outputs/.execstamp.design.svf 6-synopsys-dc-synthesis/outputs/.execstamp.design.upf 6-synopsys-dc-synthesis/outputs/.execstamp.design.v 6-synopsys-dc-synthesis/outputs/.stamp.design.namemap 6-synopsys-dc-synthesis/outputs/.stamp.design.sdc 6-synopsys-dc-synthesis/outputs/.stamp.design.svf 6-synopsys-dc-synthesis/outputs/.stamp.design.upf 6-synopsys-dc-synthesis/outputs/.stamp.design.v

.PHONY: 6

6: 6-synopsys-dc-synthesis/.execstamp 6-synopsys-dc-synthesis/.postconditions.stamp 6-synopsys-dc-synthesis/outputs/.execstamp.design.namemap 6-synopsys-dc-synthesis/outputs/.execstamp.design.sdc 6-synopsys-dc-synthesis/outputs/.execstamp.design.svf 6-synopsys-dc-synthesis/outputs/.execstamp.design.upf 6-synopsys-dc-synthesis/outputs/.execstamp.design.v 6-synopsys-dc-synthesis/outputs/.stamp.design.namemap 6-synopsys-dc-synthesis/outputs/.stamp.design.sdc 6-synopsys-dc-synthesis/outputs/.stamp.design.svf 6-synopsys-dc-synthesis/outputs/.stamp.design.upf 6-synopsys-dc-synthesis/outputs/.stamp.design.v

# debug

define 6_debug_rule
	cd 6-synopsys-dc-synthesis && ./mflowgen-debug 2>&1 | tee mflowgen-debug.log
endef

debug-synopsys-dc-synthesis: 
	$(call 6_debug_rule)

.PHONY: debug-6

debug-6: debug-synopsys-dc-synthesis

# ------------------------------------------------------------------------
# Misc
# ------------------------------------------------------------------------

# Clean

.PHONY: clean-all

clean-all:
	@find . -maxdepth 1 ! -name Makefile ! -name .mflowgen\* ! -name \. ! -name \.\. -exec rm -rf {} +

.PHONY: clean-0

clean-0:
	rm -rf ./0-arc_ram_lib

.PHONY: clean-arc_ram_lib

clean-arc_ram_lib: clean-0

.PHONY: clean-1

clean-1:
	rm -rf ./1-constraints

.PHONY: clean-constraints

clean-constraints: clean-1

.PHONY: clean-2

clean-2:
	rm -rf ./2-custom_dc_scripts

.PHONY: clean-custom_dc_scripts

clean-custom_dc_scripts: clean-2

.PHONY: clean-3

clean-3:
	rm -rf ./3-info

.PHONY: clean-info

clean-info: clean-3

.PHONY: clean-4

clean-4:
	rm -rf ./4-rtl

.PHONY: clean-rtl

clean-rtl: clean-4

.PHONY: clean-5

clean-5:
	rm -rf ./5-skywater-130nm

.PHONY: clean-skywater-130nm

clean-skywater-130nm: clean-5

.PHONY: clean-6

clean-6:
	rm -rf ./6-synopsys-dc-synthesis

.PHONY: clean-synopsys-dc-synthesis

clean-synopsys-dc-synthesis: clean-6

# Diff

.PHONY: diff-0

diff-0:
	@echo && diff -r -u --minimal --exclude={configure.yml,.time_end,.time_start,mflowgen-run*,mflowgen-debug,.stamp,inputs,outputs} ../../design/arc_ram_lib 0-arc_ram_lib | grep --color=always -e '^-.*' -e '$$' -e 'Only in ../../design/arc_ram_lib.*' | GREP_COLOR='01;32' grep --color=always -e '^+.*' -e '$$' -e 'Only in 0-arc_ram_lib.*' && echo || true

.PHONY: diff-1

diff-1:
	@echo && diff -r -u --minimal --exclude={configure.yml,.time_end,.time_start,mflowgen-run*,mflowgen-debug,.stamp,inputs,outputs} ../../design/constraints 1-constraints | grep --color=always -e '^-.*' -e '$$' -e 'Only in ../../design/constraints.*' | GREP_COLOR='01;32' grep --color=always -e '^+.*' -e '$$' -e 'Only in 1-constraints.*' && echo || true

.PHONY: diff-2

diff-2:
	@echo && diff -r -u --minimal --exclude={configure.yml,.time_end,.time_start,mflowgen-run*,mflowgen-debug,.stamp,inputs,outputs} ../../design/custom_dc_scripts 2-custom_dc_scripts | grep --color=always -e '^-.*' -e '$$' -e 'Only in ../../design/custom_dc_scripts.*' | GREP_COLOR='01;32' grep --color=always -e '^+.*' -e '$$' -e 'Only in 2-custom_dc_scripts.*' && echo || true

.PHONY: diff-3

diff-3:
	@echo && diff -r -u --minimal --exclude={configure.yml,.time_end,.time_start,mflowgen-run*,mflowgen-debug,.stamp,inputs,outputs} ../../../ee292a_lab1/mflowgen/steps/info 3-info | grep --color=always -e '^-.*' -e '$$' -e 'Only in ../../../ee292a_lab1/mflowgen/steps/info.*' | GREP_COLOR='01;32' grep --color=always -e '^+.*' -e '$$' -e 'Only in 3-info.*' && echo || true

.PHONY: diff-4

diff-4:
	@echo && diff -r -u --minimal --exclude={configure.yml,.time_end,.time_start,mflowgen-run*,mflowgen-debug,.stamp,inputs,outputs} ../../design/rtl 4-rtl | grep --color=always -e '^-.*' -e '$$' -e 'Only in ../../design/rtl.*' | GREP_COLOR='01;32' grep --color=always -e '^+.*' -e '$$' -e 'Only in 4-rtl.*' && echo || true

.PHONY: diff-5

diff-5:
	@echo && diff -r -u --minimal --exclude={configure.yml,.time_end,.time_start,mflowgen-run*,mflowgen-debug,.stamp,inputs,outputs} ../../../../../../../../farmshare/home/classes/ee/292a/skywater-130nm-adk.v2021 5-skywater-130nm | grep --color=always -e '^-.*' -e '$$' -e 'Only in ../../../../../../../../farmshare/home/classes/ee/292a/skywater-130nm-adk.v2021.*' | GREP_COLOR='01;32' grep --color=always -e '^+.*' -e '$$' -e 'Only in 5-skywater-130nm.*' && echo || true

.PHONY: diff-6

diff-6:
	@echo && diff -r -u --minimal --exclude={configure.yml,.time_end,.time_start,mflowgen-run*,mflowgen-debug,.stamp,inputs,outputs} ../../../ee292a_lab1/mflowgen/steps/synopsys-dc-synthesis 6-synopsys-dc-synthesis | grep --color=always -e '^-.*' -e '$$' -e 'Only in ../../../ee292a_lab1/mflowgen/steps/synopsys-dc-synthesis.*' | GREP_COLOR='01;32' grep --color=always -e '^+.*' -e '$$' -e 'Only in 6-synopsys-dc-synthesis.*' && echo || true

# Info

.PHONY: info-0

info-0:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t arc_ram_lib && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-info -y .mflowgen/0-arc_ram_lib/configure.yml

.PHONY: info-1

info-1:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t constraints && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-info -y .mflowgen/1-constraints/configure.yml

.PHONY: info-2

info-2:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t custom_dc_scripts && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-info -y .mflowgen/2-custom_dc_scripts/configure.yml

.PHONY: info-3

info-3:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t info && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-info -y .mflowgen/3-info/configure.yml

.PHONY: info-4

info-4:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t rtl && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-info -y .mflowgen/4-rtl/configure.yml

.PHONY: info-5

info-5:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t skywater-130nm && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-info -y .mflowgen/5-skywater-130nm/configure.yml

.PHONY: info-6

info-6:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-letters -c -t synopsys-dc-synthesis && /home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-info -y .mflowgen/6-synopsys-dc-synthesis/configure.yml

# Runtimes

.PHONY: runtimes

runtimes:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-runtimes

# List

.PHONY: list

list:
	@echo && echo Generic Targets: && echo && printf " - %s\\n" "list      -- List all steps" "status    -- Print build status for each step" "runtimes  -- Print runtimes for each step" "graph     -- Generate a PDF of the step dependency graph" "clean-all -- Remove all build directories" "clean-N   -- Clean target N" "info-N    -- Print configured info for step N" "diff-N    -- Diff target N" && echo && echo Targets: && echo && printf " - %s\\n" "  0 : arc_ram_lib" "  1 : constraints" "  2 : custom_dc_scripts" "  3 : info" "  4 : rtl" "  5 : skywater-130nm" "  6 : synopsys-dc-synthesis" && echo && echo Debug Targets: && echo && printf " - %s\\n" "debug-6  : debug-synopsys-dc-synthesis" && echo

# Graph

.PHONY: graph

graph:
	dot -Tpdf .mflowgen/graph.dot > graph.pdf

# Status

.PHONY: status

status:
	@/home/users/brionqye/Documents/EE292A/ee292a_lab1/mflowgen/mflowgen/scripts/mflowgen-status --backend make -s 0-arc_ram_lib,1-constraints,2-custom_dc_scripts,3-info,4-rtl,5-skywater-130nm,6-synopsys-dc-synthesis

