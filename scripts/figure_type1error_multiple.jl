let
	nsubj = 3:2:50
	nitem = 2:2:50

	fβ = "[2.0, 0.0]"
	fσranef = [
			#"(:subj => [1.0 0.0; 0.0 0.0])",
			#"(:subj => [2.0 0.0; 0.0 0.0])",
			#"(:subj => [3.0 0.0; 0.0 0.0])",
			"(:subj => [0.0 0.0; 0.0 0.1])",
			"(:subj => [0.0 0.0; 0.0 0.3])",
			"(:subj => [0.0 0.0; 0.0 0.5])",
			"(:subj => [0.0 0.0; 0.0 1.0])",
			"(:subj => [0.0 0.0; 0.0 2.0])",
		] 
	fσres = 0.0001
	fnoisetype = "pink"
	fnoiselevel = 1.0 
	fmodel = "lmmperm" 
	
	dir = "/Users/luis/Desktop/masterthesis/data/sanitycheck/"
	folder = "power"

	files = readdir(dir*folder, join=true)

	selectedfiles = []

	for file in files
		p = parse_savename(file)
		params_str = p[2]
		@unpack β, σranef, σres, noisetype, noiselevel, model = params_str

		# filter
		β != fβ && continue
		σranef ∉ fσranef && continue
		σres != fσres && continue
		noisetype != fnoisetype && continue
		noiselevel != fnoiselevel && continue
		model != fmodel && continue
		
		@info β, σranef, σres, noisetype, noiselevel, model	
		push!(selectedfiles, file)
	end

	theme = Attributes(
	    Axis = (
	   		xlabel = "Number of Items",
			#ylabel = "Probability",
			titlesize = 25,
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
			yminorticks = IntervalsBetween(10),
			yticks=0:5:maximum(100),
			ylabelpadding = 20,
			ylabelfont="TeX Gyre Heros Makie Bold",
			ylabelsize=25,

			aspect=1
		)
	)

	axs = []
	enum = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)"]
	
	fig = with_theme(theme) do
	    fig = Figure(
			backgroundcolor = :white,
			resolution = (1800, 1270),
			#resolution = (1800, 700),
			figure_padding = 10
		)

		for (i, file) in enumerate(selectedfiles)
			p = parse_savename(file)
			params_str = p[2]
			@unpack β, σranef, σres, noisetype, noiselevel, model = params_str
			
			
			ax = Axis(fig[fldmod1(i, 3)...],
				title = enum[i] * " " * σranef,
				ylabel = fldmod1(i, 3)[2] == 1 ? "Probability" : ""
			)

			P = readdlm(file, ',', Float64, '\n')
			labels = [string(i) for i in nsubj][begin:1:end]
			series!(nitem, P[begin:1:end,:], color=collect(cgrad(:thermal, rev = true, categorical = true, 30)), alpha=0.5, labels=labels)
			xlims!(0,maximum(nitem))
			ylims!(0,20)
			
			push!(axs, ax)
			
		end
	    fig
	end
	
	#Legend(fig[2, 3], axs[1], "Number of subjects", nbanks = 2, tellheight=false, tellwidth=false)
	Legend(fig[:, 4], axs[1], "Number of subjects", nbanks = 2)

	s1 = savename(@dict fmodel fβ fσres; connector="   |   ", 
		equals=" = ", sort=true, digits=5)
	s2 = savename(@dict fnoisetype fnoiselevel; connector="   |   ", 		equals=" = ", sort=true, digits=5)
	subtitle = replace(s1 * "   |   " * s2, "f"=>"")
	

	fig[0, :] = Label(fig, subtitle, textsize=30, font="TeX Gyre Heros Makie")
	fig[-1, :] = Label(fig, "Type 1 Error", textsize=40, font="TeX Gyre Heros Makie Bold", padding=(0,0,0,0))

	if false
		path =mkpath("/Users/luis/Desktop/masterthesis/data/sanitycheck/finalplots")
		d = @dict fmodel fβ fσres fnoisetype fnoiselevel
			sname = replace(savename(d, ".png"), "f"=>"")
			fname = replace(sname, 
				"β" => "beta",
				"σranef" => "ranef",
				"σres" => "res"
			)
		save(path*"/type1-subjslope"*fname, fig)
	end
	
	fig	
end