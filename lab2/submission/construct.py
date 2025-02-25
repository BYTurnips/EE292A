#! /usr/bin/env python
#=========================================================================
# construct.py
#=========================================================================
#
# Author : Kavya Somasi
# Date   : March 31, 2022

import os
import sys

from mflowgen.components import Graph, Step

def construct():

  g = Graph()
  g.sys_path.append( '/farmshare/home/classes/ee/292a' )


  #-----------------------------------------------------------------------
  # Parameters
  #-----------------------------------------p------------------------------

  adk_name = 'skywater-130nm-adk.v2021' ## Set the ADK here
  adk_view = 'view-standard'

  parameters = {
    'construct_path' : __file__,
    'design_name'    : 'cpu_isle',
    'adk'            : adk_name,
    'adk_view'       : adk_view,
    'topographical'  : True,
##Toggle these parameters to choose compile options
    'flatten_effort' : 3,  # Can be 0, 1, 2, 3
    'high_effort_area_opt' : True,  # Can be True, False
    'gate_clock' : True,  # Can be True, False
  }

  #-----------------------------------------------------------------------
  # Create nodes
  #-----------------------------------------------------------------------

  this_dir = os.path.dirname( os.path.abspath( __file__ ) )


  # ADK step

  g.set_adk( adk_name )
  adk = g.get_adk_step()


  # Custom steps

  rtl             = Step( this_dir + '/rtl' )
  arc_ram_lib     = Step( this_dir + '/arc_ram_lib'  )
  custom_dc_scripts = Step( this_dir + '/custom_dc_scripts'  )
  constraints     = Step( this_dir + '/constraints'  )
  
  # Default steps

  info            = Step( 'info',                          default=True )
  dc              = Step( 'synopsys-dc-synthesis',         default=True )
  #-----------------------------------------------------------------------
  # Graph -- Add nodes
  #-----------------------------------------------------------------------

  g.add_step( info            )
  g.add_step( rtl             )
  g.add_step( arc_ram_lib     )
  g.add_step( custom_dc_scripts )
  g.add_step( constraints     )
  g.add_step( dc              )

  #-----------------------------------------------------------------------
  # Graph -- Add edges
  #-----------------------------------------------------------------------
  
  # Dynamically add edges
  dc.extend_inputs(['arc_rams.db'])
  dc.extend_inputs(['extutil.v'])
  dc.extend_inputs(['jtag_defs.v'])
  dc.extend_inputs(['arcutil.v'])
  dc.extend_inputs(['arcutil_pkg_defines.v'])
  dc.extend_inputs(['asmutil.v'])
  dc.extend_inputs(['che_util.v'])
  dc.extend_inputs(['xdefs.v'])
  dc.extend_inputs(['uxdefs.v'])
  dc.extend_inputs(['ext_msb.v'])
  dc.extend_inputs(['arc600constants.v'])
  dc.extend_inputs(['generate-results.tcl'])

  # Connect by name

  g.connect_by_name( adk,             dc              )

  g.connect_by_name( rtl,             dc              )
  g.connect_by_name( arc_ram_lib,     dc              )
  g.connect_by_name( custom_dc_scripts,     dc              )
  g.connect_by_name( constraints,     dc              )
  
  #-----------------------------------------------------------------------
  # Parameterize
  #-----------------------------------------------------------------------

  g.update_params( parameters )

  return g

if __name__ == '__main__':
  g = construct()
  g.plot()
