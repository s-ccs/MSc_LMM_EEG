"""
Helper function to fit unfold model
"""
function fit_unfold_model(evts, data, times, subj)
	# basisfunction via FIR basis
	basisfunction = firbasis(τ=(-0.1,1.2), sfreq=256, name="stimulus")
	
	# formula in wilikinson notation
	f  = @formula 0~0+condA+condB;

	# map basidfunction & formula into a dict
	bfDict = Dict(Any=>(f, times));

	# filter subjects events out
	subj_evts = filter(row -> row.subject == subj, evts)
	
	# fit model
	m = fit(UnfoldModel, bfDict, subj_evts, data);

	# create result dataframe
	results = coeftable(m);

	condA = filter(row->row.coefname=="condA", results).estimate
	condB = filter(row->row.coefname=="condB", results).estimate

	return condA, condB
end;

function fit_lmm(evts, data_epoch, times)
	evts.subject  = categorical(Array(evts.subject))
	evts.stimulus  = categorical(Array(evts.stimulus))
	
	# basisfunction via FIR basis
	#basisfunction = firbasis(τ=(-0.1,1.2), sfreq=256, name="stimulus")
	
	# formula in wilikinson notation
	f = @formula 0 ~ 0 + condA + condB + (1|subject)
	contrasts = Dict(:cond => DummyCoding())


	# map basidfunction & formula into a dict
	bfDict = Dict(Any=>(f, times));
	
	# fit model
	m = fit(UnfoldModel, bfDict, evts, Base.convert(Array{Float64, 3}, data_epoch), contrasts=contrasts);

	# create result dataframe
	results = coeftable(m)
	condA = filter(row->row.coefname=="condA", results).estimate
	condB = filter(row->row.coefname=="condB", results).estimate

	return condA, condB
end