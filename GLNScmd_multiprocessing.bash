#!/bin/bash

for i in {0..9};
do
  if [ $i -eq 0 ]; then
    julia GLNScmd_standalone.jl /home/cobra/GLKH-1.1/GTSPLIB/debug/custom$i.gtsp -output=custom$i.tour -socket_port=65432 -lazy_edge_eval=0 -new_socket_each_instance=0 -mode=fast -verbose=3 &
  else
    julia GLNScmd_standalone.jl /home/cobra/GLKH-1.1/GTSPLIB/debug/custom$i.gtsp -output=custom$i.tour -socket_port=65432 -lazy_edge_eval=0 -new_socket_each_instance=0 -mode=fast -verbose=0 &
  fi
done
