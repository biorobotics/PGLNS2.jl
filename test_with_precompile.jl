using NPZ
using Printf
using Sockets
include("src/utilities.jl")
include("src/parse_print.jl")

function parse_cmd(ARGS)
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
			filename = temp[1]
		elseif length(temp) == 2
			flag = temp[1]
			value = temp[2]
			if flag in int_flags
				key = Symbol(flag[2:end])
				optional_args[key] = parse(Int64, value)
			elseif flag in float_flags
				key = Symbol(flag[2:end])
				optional_args[key] = parse(Float64, value)
			elseif flag in string_flags
				key = Symbol(flag[2:end])
				optional_args[key] = value
			else
				println("WARNING: skipping unknown flag ", flag, " in command line arguments")
			end
		else
			error("argument ", arg, " not in proper format")
		end
	end
	return filename, optional_args
end

function main(args::Vector{String}, max_time::Float64, inf_val::Int64, given_initial_tours::Vector{Int64}, do_perf::Bool, perf_file::String, dist::Matrix{Int64})
  start_time_for_tour_history = time_ns()
  problem_instance, optional_args = parse_cmd(args)
  problem_instance = String(problem_instance)

	output_file = get(optional_args, :output, "None")
  if output_file != "None"
    f = open(output_file, "w")
    write(f, "\n")
    close(f)
  end

  optional_args[Symbol("max_time")] = max_time

  evaluated_edges = Vector{Tuple{Int64, Int64}}()
  open_tsp = false

  read_start_time = time_ns()
  num_vertices, num_sets, sets, _, membership = read_file(problem_instance)
  read_end_time = time_ns()
  instance_read_time = (read_end_time - read_start_time)/1.0e9
  @printf("Reading GTSPLIB file took %f s\n", instance_read_time)

  cost_mat_read_time = 0.

  @time GLNS.solver(problem_instance, TCPSocket(), given_initial_tours, start_time_for_tour_history, inf_val, evaluated_edges, open_tsp, num_vertices, num_sets, sets, dist, membership, instance_read_time, cost_mat_read_time, do_perf, perf_file; optional_args...)
end

given_initial_tours = [   0,    1,   35,   86,   18,   69,  120,  137,  103,   52,  154,  171,  222,  205,  188,  273,  239,  256,  307,  290,  341,  324,  392,  358,  375,  426,  460,  409,  443,  494,  477,  528,  562,  511,  596,  545,  579,  613,  681,  647,  630,  664,  715,  698,  749,  732,  766,  834,  817,  783,  800,  851,  885,  868,  936,  902,  919,  970,  987,  953, 1004, 1021, 1055, 1089, 1072, 1038, 1106, 1123, 1140, 1191, 1208, 1157, 1174, 1242, 1225, 1276, 1310, 1344, 1293, 1259, 1327, 1378, 1412, 1429, 1361, 1395, 1463, 1480, 1497, 1531, 1548, 1446, 1565, 1514, 1582, 1616, 1599, 1650, 1633, 1684, 1718, 1735, 1752, 1667, 1769, 1701, 1837, 1854, 1786, 1803, 1820, 1888, 1905, 1871, 1922, 1939, 1956, 1990, 2007, 1973, 2024, 2041, 2058, 2075, 2126, 2092, 2160, 2109, 2143, 2177, 2194, 2228, 2211, 2245, 2279, 2296, 2313, 2262, 2347, 2364, 2330, 2381, 2415, 2432, 2398, 2483, 2466, 2500, 2449, 2517, 2551, 2585, 2602, 2534, 2636, 2568, 2653, 2619, 2670, 2738, 2704, 2687, 2789, 2772, 2721, 2806, 2755, 2823, 2840, 2857, 2908, 2925, 2891, 2874, 3010, 2942, 2959, 2993, 2976, 3061, 3027, 3044, 3095, 3112, 3146, 3078, 3163, 3180, 3197, 3129, 3231, 3248, 3265, 3214, 3282, 3299, 3316, 3333, 3367, 3350, 3384] .+ 1

ARGS = ["/home/cobra/GLKH-1.1/GTSPLIB/debug/custom0.gtsp", "-output=custom.tour", "-socket_port=65432", "-lazy_edge_eval=0", "-new_socket_each_instance=0", "-verbose=3", "-mode=fast"]

npyfile = first(ARGS[1], length(ARGS[1]) - length(".gtsp")) * ".npy"
dist = npzread(npyfile)

main(ARGS, 10., 298309430, given_initial_tours, false, "", dist)
main(ARGS, 10., 298309430, given_initial_tours, false, "", dist)
