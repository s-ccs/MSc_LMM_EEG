let

	fβ = "[2.0, 0.5]"
	fσranef = nothing#"(:subj => [0.0 0.0; 0.0 0.1])"
	fσres = 0.0001
	fnoisetype = "pink"
	fnoiselevel = 1.0
	#fmodel = "lmm"

	fnsubj = 7
	


	# construct subtitle
	β, σranef, σres, noisetype, noiselevel, nsubj = fβ, fσranef, fσres, fnoisetype, fnoiselevel, fnsubj 
	s1 = savename(@dict nsubj β σranef σres; connector="   |   ", equals=" = ", 
		sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	nsubj = 3:2:50
	nitem = 2:2:50

	f = Figure(
		backgroundcolor = :white,
		resolution = (1500, 800),
		figure_padding = 20
	)
	
	ax1 = Axis(
		aspect=1,
		f[1, 2],
		title = "LMM",
		titlesize = 30,
		xlabel = "Number of Items",
		ylabel = "Power",
		#subtitle = subtitle,
		subtitlesize = 25.0f0,
		subtitlegap = 10,
		titlegap = 30,
		xautolimitmargin = (0.0, 0.0),
		xminorticksvisible = true,
		xminorticks = IntervalsBetween(5),
		xticks=0:5:maximum(nitem),
		xlabelpadding = 20,
		xlabelfont="TeX Gyre Heros Makie Bold",
		xlabelsize=25,

		yautolimitmargin = (0.0, 0.0),
		yminorticksvisible = true,
		yminorticks = IntervalsBetween(5),
		yticks=0:10:maximum(100),
		ylabelpadding = 20,
		ylabelfont="TeX Gyre Heros Makie Bold",
		ylabelsize=25
	)

	xlims!(0,maximum(nitem))
	ylims!(0,100)

	ax2 = Axis(
		aspect=1,
		f[1, 1],
		title = "Two-Stage",
		titlesize = 30,
		xlabel = "Number of Items",
		ylabel = "Power",
		#subtitle = subtitle,
		subtitlesize = 25.0f0,
		subtitlegap = 10,
		titlegap = 30,
		xautolimitmargin = (0.0, 0.0),
		xminorticksvisible = true,
		xminorticks = IntervalsBetween(5),
		xticks=0:5:maximum(nitem),
		xlabelpadding = 20,
		xlabelfont="TeX Gyre Heros Makie Bold",
		xlabelsize=25,

		yautolimitmargin = (0.0, 0.0),
		yminorticksvisible = true,
		yminorticks = IntervalsBetween(5),
		yticks=0:10:maximum(100),
		ylabelpadding = 20,
		ylabelfont="TeX Gyre Heros Makie Bold",
		ylabelsize=25
	)

	xlims!(0,maximum(nitem))
	ylims!(0,100)

	dir = "/Users/luis/Desktop/masterthesis/data/experiments/"
	files = readdir(dir*"power", join=true)

	
	for fmodel in ["lmmperm", "twostage"]
		
		
		
		for file in files
			#@show file
			!endswith(file, ".csv") && continue
	
			p = parse_savename(file)
			params_str = p[2]
	
			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
	
			# filter 
			fβ != nothing && fβ != β  && continue
			fσranef  != nothing && fσranef != σranef  && continue
			fσres != nothing && fσres != σres  && continue
			fnoisetype != nothing && fnoisetype != noisetype  && continue
			fnoiselevel != nothing && fnoiselevel != noiselevel  && continue
			fmodel != nothing && fmodel != model  && continue

			# test
			startswith(σranef, "(:subj => [0.0") && continue
			!endswith(σranef, "0.0 0.0])") && continue
			endswith(σranef, "0.0 0.2])") && continue
			endswith(σranef, "0.0 0.4])") && continue
			endswith(σranef, "0.0 1.5])") && continue
			endswith(σranef, "0.0 4.0])") && continue
	
			#!all(x) && continue
	
			@show file
			P = readdlm(file, ',', Float64, '\n')
	
			ax = (fmodel == "lmmperm" ? ax1 : ax2)
			lines!(ax, collect(nitem), P[indexin(fnsubj, nsubj)[1],:], label=σranef)

			
			
			@info β, σranef, σres, noisetype, noiselevel, model
		end
	end

	#@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
	nsubj=fnsubj
	noiselevel=fnoiselevel
	s1 = savename(@dict nsubj β σres; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	s2 = savename(@dict noisetype noiselevel; connector="   |   ", 		equals=" = ", sort=true, digits=5)
	subtitle = s1 * " \n " * s2

	f[0, :] = Label(f, subtitle, textsize=30, font="TeX Gyre Heros Makie")
	f[-1, :] = Label(f, "Power (Two-Stage vs. LMM)", textsize=40, font="TeX Gyre Heros Makie Bold", padding=(0,0,0,0))
	
	Legend(f[1,3], ax2, "σranef")
	

	if false
			path =mkpath(dir * "plots-overleaf")
			d = @dict nsubj β σres noisetype noiselevel
			sname = savename(d, ".png")
			fname = replace(sname, 
				".csv"=>".png", 
				#p[1]=>"",
				"β" => "beta",
				"σranef" => "ranef",
				"σres" => "res",
				"model=lmmperm"=>""
			)
			save(dir * "plots-overleaf" * "/single-subjint-"*fname, f)
		end
	
	f
	
end