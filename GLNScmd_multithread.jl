#!/usr/bin/env julia

# Copyright 2017 Stephen L. Smith and Frank Imeson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

using Sockets
import Pkg
Pkg.activate(expanduser("~/GLNS_lazy_edge_eval.jl"))
using GLNS
using Printf

"""
Optional Flags -- values are given in square brackets []  
	-max_time=[Int]				 (default set by mode)
	-trials=[Int]				 (default set by mode)
	-restarts=[Int]              (default set by mode)
	-mode=[default, fast, slow]  (default is default)
	-verbose=[0, 1, 2, 3]        (default is 3.  0 is no output, 2 is most verbose)
	-output=[filename]           (default is output.tour)
	-epsilon=[Float in [0,1]]	 (default is 0.5)
	-reopt=[Float in [0,1]]      (default is set by mode)
	-socket_port=[Int>1023]      (default is 65432)
	-lazy_edge_eval=[Int in [0,1]]      (default is 1)
"""
function parse_cmd(ARGS, thread_idx)
	if isempty(ARGS)
		println("no input instance given")
		exit(0)
	end
	if ARGS[1] == "-help" || ARGS[1] == "--help"
		println("Usage:  GTSPcmd.jl [filename] [optional flags]\n")
		println("Optional flags (vales are give in square brackets) :\n")
		println("-mode=[default, fast, slow]      (default is default)")
		println("-max_time=[Int]                  (default set by mode)")
		println("-trials=[Int]                    (default set by mode)")
		println("-restarts=[Int]                  (default set by mode)")
		println("-noise=[None, Both, Subset, Add] (default is Both)")
		println("-num_iterations=[Int]            (default set by mode. Number multiplied by # of sets)")
		println("-verbose=[0, 1, 2, 3]            (default is 3. 0 is no output, 3 is most.)")
		println("-output=[filename]               (default is None)")
		println("-epsilon=[Float in [0,1]]        (default is 0.5)")
		println("-reopt=[Float in [0,1]]          (default is 1.0)")
		println("-budget=[Int]                    (default has no budget)")
		println("-socket_port=[Int]               (default is 65432)")
		println("-lazy_edge_eval=[Int]            (default is 1)")
		println("-new_socket_each_instance=[filename]    (default is 0)")
		exit(0)
	end
	int_flags = ["-max_time", "-trials", "-restarts", "-verbose", "-budget", "-num_iterations", "-socket_port", "-lazy_edge_eval", "-new_socket_each_instance"]
	float_flags = ["-epsilon", "-reopt"]
	string_flags = ["-mode", "-output", "-noise", "-devel"]
	filename = ""
	optional_args = Dict{Symbol, Any}()
	for arg in ARGS
		temp = split(arg, "=")
		if length(temp) == 1 && filename == ""
      filename = first(temp[1], length(temp[1]) - length(".gtsp")) * string(thread_idx) * ".gtsp"
		elseif length(temp) == 2
			flag = temp[1]
			value = temp[2]
			if flag in int_flags
				key = Symbol(flag[2:end])
        if flag == "-socket_port"
          optional_args[key] = parse(Int64, value) + thread_idx
        else
          optional_args[key] = parse(Int64, value)
        end
			elseif flag in float_flags
				key = Symbol(flag[2:end])
				optional_args[key] = parse(Float64, value)
			elseif flag in string_flags
				key = Symbol(flag[2:end])
        if flag == "-output"
          optional_args[key] = first(value, length(value) - length(".tour")) * string(thread_idx) * ".tour"
        else
          optional_args[key] = value
        end
			else
				println("WARNING: skipping unknown flag ", flag, " in command line arguments")
			end
		else
			error("argument ", arg, " not in proper format")
		end
	end
	return filename, optional_args
end


function glns_fn(thread_idx)
  problem_instance, optional_args = parse_cmd(ARGS, thread_idx)

  if haskey(optional_args, Symbol("socket_port"))
    PORT = optional_args[Symbol("socket_port")]
  else
    PORT = 65432
  end

  # Trigger just-in-time compilation before we start timing anything. This should be a GTSP with 2 sets, each with one element, and there should be an edge going both ways between the nodes
  evaluated_edges = [[1, 2], [2, 1]]
  # GLNS.solver(problem_instance, TCPSocket(), Vector{Int64}(), time_ns(), 9999, evaluated_edges, false, PORT; optional_args...)

  given_initial_tours = [   0,    1,   35,   86,   18,   69,  120,  137,  103,   52,  154,  171,  222,  205,  188,  273,  239,  256,  307,  290,  341,  324,  392,  358,  375,  426,  460,  409,  443,  494,  477,  528,  562,  511,  596,  545,  579,  613,  681,  647,  630,  664,  715,  698,  749,  732,  766,  834,  817,  783,  800,  851,  885,  868,  936,  902,  919,  970,  987,  953, 1004, 1021, 1055, 1089, 1072, 1038, 1106, 1123, 1140, 1191, 1208, 1157, 1174, 1242, 1225, 1276, 1310, 1344, 1293, 1259, 1327, 1378, 1412, 1429, 1361, 1395, 1463, 1480, 1497, 1531, 1548, 1446, 1565, 1514, 1582, 1616, 1599, 1650, 1633, 1684, 1718, 1735, 1752, 1667, 1769, 1701, 1837, 1854, 1786, 1803, 1820, 1888, 1905, 1871, 1922, 1939, 1956, 1990, 2007, 1973, 2024, 2041, 2058, 2075, 2126, 2092, 2160, 2109, 2143, 2177, 2194, 2228, 2211, 2245, 2279, 2296, 2313, 2262, 2347, 2364, 2330, 2381, 2415, 2432, 2398, 2483, 2466, 2500, 2449, 2517, 2551, 2585, 2602, 2534, 2636, 2568, 2653, 2619, 2670, 2738, 2704, 2687, 2789, 2772, 2721, 2806, 2755, 2823, 2840, 2857, 2908, 2925, 2891, 2874, 3010, 2942, 2959, 2993, 2976, 3061, 3027, 3044, 3095, 3112, 3146, 3078, 3163, 3180, 3197, 3129, 3231, 3248, 3265, 3214, 3282, 3299, 3316, 3333, 3367, 3350, 3384] .+ 1
  GLNS.solver(problem_instance, TCPSocket(), given_initial_tours, time_ns(), 9999, evaluated_edges, false, PORT; optional_args...)
  GLNS.solver(problem_instance, TCPSocket(), given_initial_tours, time_ns(), 9999, evaluated_edges, false, PORT; optional_args...)
  return

  @printf("Server attempting to listen on port %d\n", PORT)
  server = Sockets.TCPServer()
  try
    # global server = listen(PORT)
    server = listen(PORT)
  catch e
    @printf("Server on port %d failed to listen\n", PORT)
    println(e)
    exit()
  end
  @printf("Server listening on port %d\n", PORT)

  try
    client_socket = accept(server)
    @printf("Server on port %d accepted client\n", PORT)

    iter_count = 0
    while true
      #=
      if iter_count != 0 && haskey(optional_args, Symbol("new_socket_each_instance")) && optional_args[Symbol("new_socket_each_instance")] == 1
        global client_socket = accept(server)
      end
      =#
      println("getting msg")
      msg = readline(client_socket)
      println("got msg")
      start_time_for_tour_history = time_ns()
      if msg == "terminate"
        @printf("Server on port %d received termination signal", PORT)
        break
      end
      if length(msg) == 0
        iter_count += 1
        continue # Assume a client just closed its connection
      end
      if !isfile(problem_instance)
        println("the problem instance  ", problem_instance, " does not exist")
        break
      end
      msg_split = split(msg, " ")
      optional_args[Symbol("max_time")] = parse(Float64, msg_split[1])
      inf_val = parse(Int64, msg_split[2])
      given_initial_tours = Vector{Int64}()
      for node_idx_str in msg_split[3:end]
        push!(given_initial_tours, parse(Int64, node_idx_str))
      end

      # Get already evaluated edges
      evaluated_edges = Vector{Tuple{Int64, Int64}}()
      open_tsp = false
      if optional_args[Symbol("lazy_edge_eval")] == 1
        msg = readline(client_socket)
        if msg == "terminate"
          @printf("Server on port %d received termination signal", PORT)
          break
        end
        if length(msg) == 0
          iter_count += 1
          continue # Assume a client just closed its connection
        end
        msg_split = split(msg, " ")
        for edge_str in msg_split
          if edge_str == "o"
            open_tsp = true
          else
            node_strs = split(edge_str, "-")
            push!(evaluated_edges, (parse(Int64, node_strs[1]), parse(Int64, node_strs[2])))
          end
        end
      end

      # GLNS.solver(problem_instance, client_socket, given_initial_tours, start_time_for_tour_history, inf_val, evaluated_edges, open_tsp; optional_args...)
      GLNS.solver(problem_instance, client_socket, given_initial_tours, start_time_for_tour_history, inf_val, evaluated_edges, open_tsp, PORT; optional_args...)
      # GLNS.solver(problem_instance, client_socket, given_initial_tours, start_time_for_tour_history, inf_val, evaluated_edges, open_tsp, PORT; optional_args...)
      write(client_socket, "solved\n")
      iter_count += 1
    end
  catch e
    println("julia exception")
    println(e)
  finally
    close(server)
    @printf("Closed server on port %d\n", PORT)
  end
end

num_threads = Threads.nthreads()
Threads.@threads for thread_idx=0:num_threads-1
  glns_fn(thread_idx)
end
