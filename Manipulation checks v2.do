
/*************************************************************************************
* Purpose: Manipulation checks around RD thresholds as well as first stage estimates  
* Project: Tennessee QRIS 
* Created by: Scott Latham
* Created: 10/20/2017
* Last modified: 3/11/2018
* Last modified by: Scott Latham
**************************************************************************************/

use "${path}/Generated datasets/Merged TN data", clear

/*********************
* Manipulation checks
**********************/
	cap program drop hists
	program define hists
		args samp dv dvtit xlines opts
		
		loc gph ""
		
		forvalues i = 0/11	{
			loc evalnum = `i' + 1
			
			count if `dv'_`i' !=. & `samp'==1
			loc N = r(N)
			
			hist `dv'_`i'  if `samp'==1, fraction xline(`xlines', lcolor(black)) ///
				title("`evalnum'") note("N=`N'", pos(6)) xtitle("") `opts' ///
				saving("${path}\Figures\h`i'.gph", replace) nodraw
			
			loc gph "`gph' h`i'.gph"
		}
		
		cd "${path}\Figures"	
		graph combine `gph', subtitle("`dvtit'", pos(6)) ycommon title("ERS rating across evaluations")
		graph export "${path}\Figures/Histograms over time `dv' `samp'.pdf", replace

		foreach x in `gph'	}
			erase `x'
		}
		
	end //ends program hists	

	hists center_all score_total "Total QRIS score" "4 11 18" 	"xlabel(0 4 11 18 23) xscale(range(0 23)) width(1) start(0)"
	hists center_fr score_total "Total QRIS score" "4 11 18" 	"xlabel(0 4 11 18 23) xscale(range(0 23)) width(1) start(0)"
	
	hists FGH_all score_total "Total QRIS score" "3 8 13" "xlabel(0 3 8 13 17) xscale(range(0 15)) width(1) start(0)"
	hists FGH_fr score_total "Total QRIS score" "3 8 13" "xlabel(0 3 8 13 17) xscale(range(0 15)) width(1) start(0)"
	
	
	hists center_all ERS_rating "ERS rating" "4 4.5 5" 	"xlabel(0(1)7, format(%3.0f)) xscale(range(0 7)) width(.25) start(0)"
	
	
	
	cap program drop mccrarys
	program define mccrarys
		args fv break type bin
		
		forvalues i = 0/11	{
			cap drop Xj Yj r0 fhat se_fhat
			DCdensity `fv'_`i' if `type', ///
				breakpoint(`break') generate(Xj Yj r0 fhat se_fhat) h(.5) `bin' graphname("${path}\Figures\mc`i'") 
			
			loc gph "`gph' mc`i'.gph"
		}

		cd "${path}\Figures"
		graph combine `gph', ycommon title("McCrary test across evaluations (`break' ERS cutoff)")
		graph export "${path}\Figures\McCrary over time.pdf", replace
		
		
		foreach x in `gph'	{
			erase `x'
		}
		
	end //Ends program mccrarys
		
		
	//Average total score
		mccrarys score_total 11	"center_all" "b(1)"
		mccrarys score_total 18	"center_all" "b(1)"
		
		mccrarys score_total 	8	"FGH_all" "b(1)"
		mccrarys score_total 	13	"FGH_all" "b(1)" 
		
		
		mccrarys ERS_rating		3.0	"center_all" "b(.125)"
		mccrarys ERS_rating		4.0	"center_all" "b(.125)"
		mccrarys ERS_rating		4.5	"center_all" "b(.125)"
		mccrarys ERS_rating		5.0	"center_all" "b(.125)"
		mccrarys ERS_rating		5.5	"center_all" "b(.125)"
		mccrarys ERS_rating		6.0	"center_all" "b(.125)"

		//Histograms		
	*****************
		*Average total score
			hist score_avg_0  if center==1, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
			hist score_avg_0  if center==0, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
			//hist score_avg_0  if center==0, start(0) width(.25) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
		
		*ERS rating
			hist ERS_rating_0 if center_all, start(0)	width(.125) xline(4 4.5 5, lcolor(black)) xtitle("Initial ERS rating") freq
			hist ERS_rating_0 if center==0, start(0)	width(.125) xline(4 4.5 5, lcolor(black)) xtitle("Initial ERS rating") freq
		
		*Frontier RD (total score conditional on ERS rating >=4.0)
			hist score_avg_0  if center==1 & ERS_rating_0 >=4.0, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
			hist score_avg_0  if center==0 & ERS_rating_0 >=4.0, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
			
		//Revised histograms
		cd "$path\Figures"
		
		hist score_avg_0  if center_all, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components")  freq ///
			 saving("$path\Figures\g1", replace)
			 
		hist score_avg_0  if center_all, start(0) width(.0625) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq ///
			saving("$path\Figures\g2", replace)	
				
		graph combine g1.gph g2.gph, title("Full sample") row(2)
		graph export "Full sample histogram.png", replace
		
		
		hist score_avg_0  if center_fr, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components")  freq ///
			 saving("$path\Figures\g1", replace)
			 
		hist score_avg_0  if center_fr, start(0) width(.0625) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq ///
			saving("$path\Figures\g2", replace)	

		graph combine g1.gph g2.gph, title("Frontier RD sample") row(2)
		graph export "Frontier sample histogram.png", replace
		
		
		hist ERS_rating_1  if center_all, start(0) width(.25) xline(4.0, lcolor(black)) xtitle("ERS rating")  freq 
		graph export "${path}\Figures\ERS rating 4.0 cutoff.png", replace	 
			 
		hist ERS_rating_1  if center_all, start(0) width(.125) xline(4.0, lcolor(black)) xtitle("ERS rating")  freq ///
			saving("$path\Figures\g2", replace)	

		graph combine g1.gph g2.gph, title("") row(2)
		graph export "Frontier sample histogram.png", replace
		

		
		cap drop Xj Yj r0 fhat se_fhat
		DCdensity ERS_rating_1 if center_all, breakpoint(4.0) generate(Xj Yj r0 fhat se_fhat)
		
	//McCrary tests
	******************
		cap program drop mccrary
		program define mccrary
			args fv break type bin
			
			cap drop Xj Yj r0 fhat se_fhat
			DCdensity `fv'_0 if `type', breakpoint(`break') generate(Xj Yj r0 fhat se_fhat) `bin'
			
		end //Ends program mccrary
		
		use "${path}/Generated datasets/Merged TN data", clear
		//Average total score
			mccrary score_avg 	0.5	"center==1 & abs(score_avg_c1) < 1" "b(.15)" //Probably OK with or w/o restriction
			mccrary score_avg 	1.5	"center==1 & abs(score_avg_c2) < 1" "b(.15)" //Bueno
		
			mccrary score_avg 	2.5	"center_all" "b(.15)" //Not even close to bueno
			mccrary score_avg 	2.5	"center_fr" "b(.15)" 
		
			mccrary score_avg 	0.5	"center==0" "b(.15)"
			mccrary score_avg 	1.5	"center==0" "b(.15)"
			mccrary score_avg 	2.5	"center==0" "b(.15)"

			
		//ERS rating
			mccrary ERS_rating 	4 	"center==1"		//No bueno	
			mccrary ERS_rating 	4.5 "center==1 &  abs(ERS_rating_c2) <=.5" "b(.05)" //Bueno

			mccrary ERS_rating 	5 	"center==1" "b(.05)" //Looks fine w/o BW restriction, no good with BW restriction		
			mccrary ERS_rating 	5 	"center==1 & abs(ERS_rating_c3) <.5" "b(.01)"
			
			mccrary ERS_rating 	4 	"center==0"
			mccrary ERS_rating 	4.5 "center==0 & abs(ERS_rating_c2) < .5"
			mccrary ERS_rating 	5 	"center==0 & abs(ERS_rating_c3) < .5"
			

		//Frontier RD (total score conditional on ERS >=4.0)		
			mccrary score_avg 	0.5	"center==1 & ERS_rating1 >=4.0" "b(.15)" //
			mccrary score_avg 	1.5	"center==1 & ERS_rating1 >=4.0 & abs(score_avg_c2) < 1" "b(.15)" //
			mccrary score_avg 	2.5	"center==1 & ERS_rating1 >=4.0 & abs(score_avg_c3) < 1" "b(.15)" //

			mccrary score_avg 	0.5	"center==0 & ERS_rating1 >=4.0" "b(.15)" //
			mccrary score_avg 	1.5	"center==0 & ERS_rating1 >=4.0 & abs(score_avg_c2) < 1" "b(.075)" //
			mccrary score_avg 	2.5	"center==0 & ERS_rating1 >=4.0" "b(.15)" //
			
			
	//Tabulations
	*****************
		cap program drop tabs
		program tabs
			args fv type
			
			tab `fv'_0 if abs(`fv'_c1) < 4 & `type'
			tab `fv'_0 if abs(`fv'_c2) < .2 & `type'
			tab `fv'_0 if abs(`fv'_c3) < .2 & `type'
			
		end //Ends program tabs

		tabs ERS_rating "center==1"
		tabs score_avg 	"center==1"
		
		tabs ERS_rating "center==0"
		tabs score_avg "center==0"
	
	//Tabulations Excluding 2009 first evaluations 
		cap program drop tabs
		program tabs
			args fv type
			
			tab `fv'_0 if abs(`fv'_c1) < 4 & `type' & year_effective_0 != 2009 
			
		end //Ends program tabs

		*tabs ERS_rating "center==1"
		tabs score_avg 	"center==1"
		
		*tabs ERS_rating "center==0"
		tabs score_avg "center==0"
	
	
	//What % of observations on each side of cut point?
		tab ERS_rating_cut_1 if center==1
		tab ERS_rating_cut_2 if center==1
		tab ERS_rating_cut_3 if center==1
		
		tab ERS_rating_cut_1 if center==0
		tab ERS_rating_cut_2 if center==0
		tab ERS_rating_cut_3 if center==0	
	
		tab score_avg_cut_1 if center==1
		tab score_avg_cut_2 if center==1
		tab score_avg_cut_3 if center==1
		
		tab score_avg_cut_1 if center==0
		tab score_avg_cut_2 if center==0
		tab score_avg_cut_3 if center==0
		
		
		
	/* Continuity of baseline covariates
	*************************************/
		use "${path}/Generated datasets/Merged TN data", clear
		
		//Estimates
		cap program drop covars
		program covars
			args dvs fv samp			
			
			mat table = J(1,10,.)
			
			foreach dv in `dvs'	{
				
				mat row = [.]
				
				forvalues i = 1/3	{
				
					loc fv_vals "`fv'_c`i' `fv'_cut_`i' `fv'_int_`i' `fv'_sq_`i' `fv'_intsq_`i'"
					
					reg `dv' `fv_vals' if `samp', robust
					
						loc coef: 	di %4.3f _b[`fv'_cut_`i']
						loc se: 	di %4.3f _se[`fv'_cut_`i']
					
						loc t: 		di %4.3f (`coef' / `se')
					
					mat row = [row, `coef', `se', `t' ]
				}	
				
				mat table = [table \ row] 
			}
					
			mat table = table[2..., 2...] //trim blank row & column
			
			mat rownames table = `dvs'
			mat colnames table = coef1 se1 t1 coef2 se2 t2 coef3 se3 t3
			
			mat list table

		end //Ends program covars
		
		# delimit ;
		
		gl covars "tot_staff subsidy scholarship sliding_fee multi_discount capacity_0 enr_sub_total_0 enr_sub_white_0 enr_sub_black_0 
						enr_sub_hisp_0 enr_sub_asian_0 years_open family group dept_of_ed dept_of_hs " ;
		
		# delimit cr
		
		covars "$covars" score_avg center_all
		covars "$covars" ERS_rating center_all	
		covars "$covars" score_avg center_fr
		
		covars "$covars" score_avg FGH_std	
		covars "$covars" ERS_rating FGH_std	
		covars "$covars" score_avg FGH_fr

		//covars "$components" score_avg center_all
	
		//Figures
		************

		use "${path}/Generated datasets/Merged TN data", clear
		
		gl bin	".1"	// Bin width (for binned scatter plots)	
		gl band	"3" 	// 1/2 bandwidth for RD estimation (above and below cut)
		
			//Draws a binned scatterplot for observables (Needs to be run before using cov_figs)
				capture program drop bin_plot
				program define bin_plot
					args yvar ylab fv cut samp sampname gname

					
					preserve
						keep if `samp' //Choose sample here

						loc fvlabel: variable label `fv'_c`cut'
						keep if abs(`fv'_c`cut') <= $band //Restrict the sample to observations near the cut point
							
						//Construct binned outcomes							
							gen bin = `fv'_c`cut' - mod(`fv'_c`cut', $bin) + $bin/2
							egen tag = tag(bin) //Only need 1 observation since they are means

							egen out_mean = mean(`yvar'), by(bin)	
			
			
						//Estimate regression, to put in graph
							reg `yvar' `fv'_c`cut' `fv'_cut_`cut' `fv'_int_`cut' `fv'_sq_`cut' `fv'_intsq_`cut', robust
								loc coef: 	di %4.3f _b[`fv'_cut_`cut']
								loc se: 	di %4.3f _se[`fv'_cut_`cut']
								
								loc est "Discontinuity estimate: `coef' (`se')"
								
						//Graph binned data separately on each side of the threshold
							
						
							twoway  (scatter out_mean bin if `fv'_c`cut' <0  & tag, msymbol(circle) msize(medsmall) mcolor(navy)) ///
									(scatter out_mean bin if `fv'_c`cut' >=0 & tag, msymbol(circle) msize(medsmall) mcolor(navy)) ///
									(qfit `yvar' `fv'_c`cut' if `fv'_c`cut' <=0, lwidth(medthick) lcolor(black)) ///
									(qfit `yvar' `fv'_c`cut' if `fv'_c`cut' >=0, lwidth(medthick) lcolor(black))	, ///
										xtitle("`fvlabel'") xline(0, lcolor(black)) ///
										ytitle("`ylab' in initial year") leg(off) 	///				
										title("`ylab'") note(`est', ring(1) pos(5)) caption("Bin size: $bin", pos(7))
										
							//graph export "${path}\Figures/Covbal - `yvar' `fv'_c`cut' `samp'.png", replace
							graph save "${path}\Figures/`gname'", replace		
						
					restore
						
				end //ends program bin_plot			
	
		cap program drop cov_figs
		program cov_figs
			args fv cut samp samplab
			
			cd "$path\Figures"
			
			bin_plot years_open_0 		"Years open at baseline"			`fv' `cut' `samp' "`samplab'" 1
			bin_plot tot_staff 			"Total staff" 						`fv' `cut' `samp' "`samplab'" 2
			
			graph combine 1.gph 2.gph
			graph export "Covbal - Years open & staff (`fv' `cut' `samp').pdf", replace
			
			
			bin_plot subsidy 			"Subsidy available"					`fv' `cut' `samp' "`samplab'" 1
			bin_plot scholarship 		"Scholarships available"			`fv' `cut' `samp' "`samplab'" 2
			bin_plot sliding_fee 		"Sliding fee scale"					`fv' `cut' `samp' "`samplab'" 3
			bin_plot multi_discount 	"Multi child discount"				`fv' `cut' `samp' "`samplab'" 4
			
			graph combine 1.gph 2.gph 3.gph 4.gph, ycommon
			graph export "Covbal - Financial aid (`fv' `cut' `samp').pdf", replace
			
			bin_plot capacity_0 		"Licensed capacity"					`fv' `cut' `samp' "`samplab'" 1
			bin_plot enr_sub_total_0 	"Total subsidized enrollment"		`fv' `cut' `samp' "`samplab'" 2
			bin_plot enr_sub_pct_0		"Pct subsidized enrollment"			`fv' `cut' `samp' "`samplab'" 3
					
			graph combine 1.gph 2.gph 3.gph
			graph export "Covbal - Enrollment & capacity (`fv' `cut' `samp').pdf", replace
			pause
			
			bin_plot enr_sub_white_0 	"White subsidized enrollment"		`fv' `cut' `samp' "`samplab'" 1
			bin_plot enr_sub_black_0 	"Black subsidized enrollment"		`fv' `cut' `samp' "`samplab'" 2
			bin_plot enr_sub_hisp_0 	"Hispanic subsidized enrollment"	`fv' `cut' `samp' "`samplab'" 3 
			bin_plot enr_sub_asian_0 	"Asian subsidized enrollment"		`fv' `cut' `samp' "`samplab'" 4
			
			graph combine 1.gph 2.gph 3.gph 4.gph, ycommon				
			graph export "Covbal - Enrollment by race (`fv' `cut' `samp').pdf", replace
			
			bin_plot family 			"Family care home"					`fv' `cut' `samp' "`samplab'" 1
			bin_plot group 				"Group home"						`fv' `cut' `samp' "`samplab'" 2
			bin_plot dept_of_ed 		"Department of Education"			`fv' `cut' `samp' "`samplab'" 3
			bin_plot dept_of_hs 		"Department of Human Services"		`fv' `cut' `samp' "`samplab'" 4
			
			graph combine 1.gph 2.gph 3.gph 4.gph, ycommon
			graph export "Covbal - Auspice (`fv' `cut' `samp').pdf", replace
			
		end //ends program cov_figs
		

		//Centers
		***********
		
		//Average QRIS score
			cov_figs score_avg 1 center_std "All centers"
			cov_figs score_avg 2 center_std "All centers"
			cov_figs score_avg 3 center_std "All centers"
		
		//ERS ratings
			cov_figs ERS_rating 1 center_std "All centers"
			cov_figs ERS_rating 2 center_std "All centers"
			cov_figs ERS_rating 3 center_std "All centers"	
			
		//Frontier RD
			cov_figs score_avg 1 center_fr "Frontier - center"
			cov_figs score_avg 2 center_fr "Frontier - center"
			cov_figs score_avg 3 center_fr "Frontier - center"		
				
				
		//Family & group homes
		**********************
				
		//Average QRIS score
			cov_figs score_avg 1 FGH_std "All FGHs"
			cov_figs score_avg 2 FGH_std "All FGHs"
			cov_figs score_avg 3 FGH_std "All FGHs"
		
		//ERS ratings
			cov_figs ERS_rating 1 FGH_std "All FGHs"
			cov_figs ERS_rating 2 FGH_std "All FGHs"
			cov_figs ERS_rating 3 FGH_std "All FGHs"	
			
		//Frontier RD
			cov_figs score_avg 1 FGH_fr "Frontier - FGH"
			cov_figs score_avg 2 FGH_fr "Frontier - FGH"
			cov_figs score_avg 3 FGH_fr "Frontier - FGH"			
				
	
	**********************************************************************
	
	gl components	"score_dir_qual_0 score_prof_dev_0 score_comp_hist_0 score_par_inv_0 score_ratio_0 score_staff_comp_0 score_assess_0 "
	
	mat table = J(1,4,.)
	
	foreach x in $components	{
		count if `x' !=. & center_fr
		loc N = r(N)
		
		forvalues i = 0/3	{
			count if `x' ==`i' & center_fr
			loc n`i' = r(N)
			loc val`i': di %4.3f `n`i''/`N'
		}
		mat row = [`val0' , `val1' , `val2' , `val3']
		mat table = [table \ row]	
		
	}
	mat rownames table = blank $components
	mat list table

		
		use "${path}/Generated datasets/Merged TN data", clear
		
		gl bin	".1"	// Bin width (for binned scatter plots)	
		gl band	"3" 	// 1/2 bandwidth for RD estimation (above and below cut)
		
			//Draws a binned scatterplot for observables (Needs to be run before using cov_figs)
				capture program drop bin_plot_2
				program define bin_plot_2
					args yvar ylab fv cut samp gname

					
					preserve
						keep if `samp' //Choose sample here
		
						loc fvlabel: variable label `fv'_c`cut'
						keep if abs(`fv'_c`cut') <= $band //Restrict the sample to observations near the cut point
							
						//Construct binned outcomes							
							gen bin = `fv'_c`cut' - mod(`fv'_c`cut', $bin) + $bin/2
							egen tag = tag(bin) //Only need 1 observation since they are means

							bysort bin: egen weight = count(bin)

							egen out_mean = mean(`yvar'), by(bin)	
			
			
						//Estimate regression, to put in graph
							reg `yvar' `fv'_c`cut' `fv'_cut_`cut' `fv'_int_`cut' `fv'_sq_`cut' `fv'_intsq_`cut', robust
								loc coef: 	di %4.3f _b[`fv'_cut_`cut']
								loc se: 	di %4.3f _se[`fv'_cut_`cut']
								
								loc est "Discontinuity estimate: `coef' (`se')"
								
						//Graph binned data separately on each side of the threshold
							
						
							twoway  (scatter out_mean bin if `fv'_c`cut' <0  & tag, msymbol(circle) mcolor(navy)) ///
									(scatter out_mean bin if `fv'_c`cut' >=0 & tag, msymbol(circle) mcolor(navy)) ///
									(qfit `yvar' `fv'_c`cut' if `fv'_c`cut' <=0, lwidth(medthick) lcolor(black)) ///
									(qfit `yvar' `fv'_c`cut' if `fv'_c`cut' >=0, lwidth(medthick) lcolor(black))	, ///
										xtitle("`fvlabel'") xline(0, lcolor(black)) ///
										ytitle("Score in initial year") leg(off) 	///				
										title("`ylab'") note(`est', ring(1) pos(5)) caption("Bin size: $bin", pos(7))
										
							//graph export "${path}\Figures/Covbal - `yvar' `fv'_c`cut' `samp'.png", replace
							graph save "${path}\Figures/`gname'", replace		
						
					restore
						
				end //ends program bin_plot			
			
			//Full sample	
				bin_plot_2	score_dir_qual_0	"Director qualifications"	score_avg 3 center_all 1
				bin_plot_2	score_prof_dev_0	"Professional development"	score_avg 3 center_all 2
				bin_plot_2	score_comp_hist_0	"Compliance history"		score_avg 3 center_all 3
				bin_plot_2	score_par_inv_0		"Parental involvement"		score_avg 3 center_all 4
				
				cd "$path\Figures"
				graph combine 1.gph 2.gph 3.gph 4.gph , title(Distribution of QRIS components across 2.5 threshold) ycommon
				graph export "${path}\Figures\Component binscatters - full sample (p1).png", replace
				
				
				bin_plot_2	score_ratio_0		"Ratio & group size"		score_avg 3 center_all 1
				bin_plot_2	score_staff_comp_0	"Staff compensation"		score_avg 3 center_all 2
				bin_plot_2	score_assess_0		"Program assessment (ERS)"	score_avg 3 center_all 3
		
				cd "$path\Figures"
				graph combine 1.gph 2.gph 3.gph  , title("Distribution of QRIS components across 2.5 threshold (ctd)") ycommon
				graph export "${path}\Figures\Component binscatters - full sample (p2).png", replace
	
		
			//Frontier sample
				bin_plot_2	score_dir_qual_0	"Director qualifications"	score_avg 3 center_fr 1
				bin_plot_2	score_prof_dev_0	"Professional development"	score_avg 3 center_fr 2
				bin_plot_2	score_comp_hist_0	"Compliance history"		score_avg 3 center_fr 3
				bin_plot_2	score_par_inv_0		"Parental involvement"		score_avg 3 center_fr 4
				
				cd "$path\Figures"
				graph combine 1.gph 2.gph 3.gph 4.gph , title(Distribution of QRIS components across 2.5 threshold) ycommon
				graph export "${path}\Figures\Component binscatters - frontier sample (p1).png", replace
				
				
				bin_plot_2	score_ratio_0		"Ratio & group size"		score_avg 3 center_fr 1
				bin_plot_2	score_staff_comp_0	"Staff compensation"		score_avg 3 center_fr 2
				bin_plot_2	score_assess_0		"Program assessment (ERS)"	score_avg 3 center_fr 3
		
				cd "$path\Figures"
				graph combine 1.gph 2.gph 3.gph  , title("Distribution of QRIS components across 2.5 threshold (ctd)") ycommon
				graph export "${path}\Figures\Component binscatters - frontier sample (p2).png", replace	
