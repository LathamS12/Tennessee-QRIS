
/*************************************************************************************
* Purpose: Manipulation checks around RD thresholds as well as first stage estimates  
* Project: Tennessee QRIS 
* Created by: Scott Latham
* Created: 10/20/2017
* Last modified: 2/11/2018
* Last modified by: Scott Latham
**************************************************************************************/

use "${path}/Generated datasets/Merged TN data", clear

/*********************
* Manipulation checks
**********************/

	//Histograms		
	
		*Average total score
			hist score_avg1  if center==1, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
			hist score_avg1  if center==0, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
			//hist score_avg1  if center==0, start(0) width(.25) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
		
		*ERS rating
			hist ERS_rating1 if center==1, start(0)	width(.125) xline(4 4.5 5, lcolor(black)) xtitle("Initial ERS rating") freq
			hist ERS_rating1 if center==0, start(0)	width(.125) xline(4 4.5 5, lcolor(black)) xtitle("Initial ERS rating") freq
		
		*Frontier RD (total score conditional on ERS rating >=4.0)
			hist score_avg1  if center==1 & ERS_rating1 >=4.0, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
			hist score_avg1  if center==0 & ERS_rating1 >=4.0, start(0) width(.125) xline(0.5 1.5 2.5, lcolor(black)) xtitle("Avg score across QRIS components") freq
						
			
	//McCrary tests
		cap program drop mccrary
		program define mccrary
			args fv break type bin
			
			cap drop Xj Yj r0 fhat se_fhat
			DCdensity `fv'1 if `type', breakpoint(`break') generate(Xj Yj r0 fhat se_fhat) `bin'
			
		end //Ends program mccrary
		
		//Average total score
			mccrary score_avg 	0.5	"center==1 & abs(score_avg_c1) < 1" "b(.15)" //Probably OK with or w/o restriction
			mccrary score_avg 	1.5	"center==1 & abs(score_avg_c2) < 1" "b(.15)" //Bueno
			mccrary score_avg 	2.5	"center==1 & abs(score_avg_c3) < 1" "b(.15)" //Not even close to bueno
		
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
		cap program drop tabs
		program tabs
			args fv type
			
			tab `fv'1 if abs(`fv'_c1) < 4 & `type'
			tab `fv'1 if abs(`fv'_c2) < .2 & `type'
			tab `fv'1 if abs(`fv'_c3) < .2 & `type'
			
		end //Ends program tabs

		tabs ERS_rating "center==1"
		tabs score_avg 	"center==1"
		
		tabs ERS_rating "center==0"
		tabs score_avg "center==0"
	
	//Tabulations Excluding 2009 first evaluations 
		cap program drop tabs
		program tabs
			args fv type
			
			tab `fv'1 if abs(`fv'_c1) < 4 & `type' & year_effective1 != 2009 
			
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
			args dvs
			
			loc center = "center==1 & nonmissing==1" 
			loc fgh = "center==0 & nonmissing==1" 
			
			loc fv_vals_1 "score_avg_c1 score_avg_cut_1 score_avg_int_1 score_avg_sq_1 score_avg_intsq_1"
			loc fv_vals_2 "score_avg_c2 score_avg_cut_2 score_avg_int_2 score_avg_sq_2 score_avg_intsq_2"
			loc fv_vals_3 "score_avg_c3 score_avg_cut_3 score_avg_int_3 score_avg_sq_3 score_avg_intsq_3"
			
			foreach dv in `dvs'	{
				eststo: reg `dv' `fv_vals_1' if `center', robust
				eststo: reg `dv' `fv_vals_2' if `center', robust
				eststo: reg `dv' `fv_vals_3' if `center', robust
				
				cd "${path}/Tables/Baseline Covariates/Center"

					esttab using "`dv'.csv", b(%9.3fc) se(%9.3fc) star(* 0.1 ** 0.05 *** 0.01) label r2(4) ///
						title("Centers: Cov. `dv' at Threshold") replace
					
				eststo clear 
			
				pause
			}
			
			foreach dv in `dvs'	{
				eststo: reg `dv' `fv_vals_1' if `fgh', robust
				eststo: reg `dv' `fv_vals_2' if `fgh', robust
				eststo: reg `dv' `fv_vals_3' if `fgh', robust
				
				cd "${path}/Tables/Baseline Covariates/FGH"

					esttab using "`dv'.csv", b(%9.3fc) se(%9.3fc) star(* 0.1 ** 0.05 *** 0.01) label r2(4) ///
						title("FGH: Cov. `dv' at Threshold") replace
					
				eststo clear 
			
				pause
			}
			
		end
	
		//			dv																																		
		covars "tot_staff subsidy scholarship sliding_fee multi_discount capacity1 enr_sub_total_1 enr_sub_white_1 enr_sub_black_1 enr_sub_hisp_1 enr_sub_asian_1 years_open family group dept_of_ed dept_of_hs"

	
		//Figures
		cap program drop baseline_fig
		program baseline_fig
			args dv dvtit
		
			loc center = "center==1 & nonmissing==1" 
			loc fgh = "center==0 & nonmissing==1" 
			
			loc first = "0.5"
			loc second = "1.5"
			loc third = "2.5"
			
			// Centers
			preserve
				keep if `center' //& ERS_rating1 >4 //Limit to centers or family/group homes
				keep if `dv'!=. // Keeps only observations where covariate isn't missing == > matches regression tables. 
		
				loc n = _N
				
				loc fv1 "score_avg_c1"	 //e.g. ERS_rating_c1
				loc fv2 "score_avg_c2"	 //e.g. ERS_rating_c1
				loc fv3 "score_avg_c3"	 //e.g. ERS_rating_c1

				loc bin  ".05" //Bin width

				//Plot binned outcomes on either side of cut points
					
					//First, construct bins
					gen bin1 = `fv1' - mod(`fv1', `bin') + `bin'/2		
					sort bin1
					egen tag1 = tag(bin1) //Only need 1 observation since they are means
					
					gen bin2 = `fv2' - mod(`fv2', `bin') + `bin'/2		
					sort bin2
					egen tag2 = tag(bin2) //Only need 1 observation since they are means
					
					gen bin3 = `fv3' - mod(`fv3', `bin') + `bin'/2		
					sort bin3
					egen tag3 = tag(bin3) //Only need 1 observation since they are means
		
					//Then plot them
					
						egen `dv'_mean1 = mean(`dv'), by(bin1) //construct binned outcomes	
						egen `dv'_mean2 = mean(`dv'), by(bin2) //construct binned outcomes	
						egen `dv'_mean3 = mean(`dv'), by(bin3) //construct binned outcomes	

				
					// First Threshold 
						twoway  (scatter `dv'_mean1 bin1 if tag1, msymbol(circle) msize(small) mcolor(black)) ///	
								(qfit `dv' `fv1' if `fv1' <0 , lwidth(medthick) lcolor(navy)) ///
								(qfit `dv' `fv1' if `fv1' >=0, lwidth(medthick) lcolor(navy)), ///
									leg(off) xline(0)	 ///
									xtitle("Average score centered at 0.5") ytitle("p(`dvtit')") caption("N = `n'") ///
									saving("${path}/Figures/Baseline Covariates/Center/`dv'_0.5", replace)	
										
						graph export "${path}/Figures/Baseline Covariates/Center/`dv'_`cutnum'_fv1'.png", replace
					
					// Second Threshold 
						twoway  (scatter `dv'_mean2 bin2 if tag2, msymbol(circle) msize(small) mcolor(black)) ///	
								(qfit `dv' `fv2' if `fv2' <0 , lwidth(medthick) lcolor(navy)) ///
								(qfit `dv' `fv2' if `fv2' >=0, lwidth(medthick) lcolor(navy)), ///
									leg(off) xline(0)	 ///
									xtitle("Average score centered at 1.5") ytitle("p(`dvtit')") caption("N = `n'") ///
									saving("${path}/Figures/Baseline Covariates/Center/`dv'_1.5", replace)	
										
						graph export "${path}/Figures/Baseline Covariates/Center/`dv'_`cutnum'_fv2'.png", replace
					
					// Third Threshold 
						twoway  (scatter `dv'_mean3 bin3 if tag3, msymbol(circle) msize(small) mcolor(black)) ///	
								(qfit `dv' `fv3' if `fv3' <0 , lwidth(medthick) lcolor(navy)) ///
								(qfit `dv' `fv3' if `fv3' >=0, lwidth(medthick) lcolor(navy)), ///
									leg(off) xline(0)	 ///
									xtitle("Average score centered at 2.5") ytitle("p(`dvtit')") caption("N = `n'") ///
									saving("${path}/Figures/Baseline Covariates/Center/`dv'_2.5", replace)	
										
						graph export "${path}/Figures/Baseline Covariates/Center/`dv'_`cutnum'_fv3'.png", replace
					
				restore
				
				
				// FGH
				preserve
				keep if `fgh' //& ERS_rating1 >4 //Limit to centers or family/group homes
				keep if `dv'!=. // Keeps only observations where covariate isn't missing == > matches regression tables. 
				
				loc n = _N
				
				loc fv1 "score_avg_c1"	 //e.g. ERS_rating_c1
				loc fv2 "score_avg_c2"	 //e.g. ERS_rating_c1
				loc fv3 "score_avg_c3"	 //e.g. ERS_rating_c1

				loc bin  ".05" //Bin width

				//Plot binned outcomes on either side of cut points
					
					//First, construct bins
					gen bin1 = `fv1' - mod(`fv1', `bin') + `bin'/2		
					sort bin1
					egen tag1 = tag(bin1) //Only need 1 observation since they are means
					
					gen bin2 = `fv2' - mod(`fv2', `bin') + `bin'/2		
					sort bin2
					egen tag2 = tag(bin2) //Only need 1 observation since they are means
					
					gen bin3 = `fv3' - mod(`fv3', `bin') + `bin'/2		
					sort bin3
					egen tag3 = tag(bin3) //Only need 1 observation since they are means
		
					//Then plot them
					
						egen `dv'_mean1 = mean(`dv'), by(bin1) //construct binned outcomes	
						egen `dv'_mean2 = mean(`dv'), by(bin2) //construct binned outcomes	
						egen `dv'_mean3 = mean(`dv'), by(bin3) //construct binned outcomes	

				
					// First Threshold 
						twoway  (scatter `dv'_mean1 bin1 if tag1, msymbol(circle) msize(small) mcolor(black)) ///	
								(qfit `dv' `fv1' if `fv1' <0 , lwidth(medthick) lcolor(navy)) ///
								(qfit `dv' `fv1' if `fv1' >=0, lwidth(medthick) lcolor(navy)), ///
									leg(off) xline(0)	 ///
									xtitle("Average score centered at 0.5") ytitle("p(`dvtit')") caption("N = `n'") ///
									saving("${path}/Figures/Baseline Covariates/FGH/`dv'_0.5", replace)	
										
						graph export "${path}/Figures/Baseline Covariates/FGH/`dv'_`cutnum'_fv1'.png", replace
					
					// Second Threshold 
						twoway  (scatter `dv'_mean2 bin2 if tag2, msymbol(circle) msize(small) mcolor(black)) ///	
								(qfit `dv' `fv2' if `fv2' <0 , lwidth(medthick) lcolor(navy)) ///
								(qfit `dv' `fv2' if `fv2' >=0, lwidth(medthick) lcolor(navy)), ///
									leg(off) xline(0)	 ///
									xtitle("Average score centered at 1.5") ytitle("p(`dvtit')") caption("N = `n'") ///
									saving("${path}/Figures/Baseline Covariates/FGH/`dv'_1.5", replace)	
										
						graph export "${path}/Figures/Baseline Covariates/FGH/`dv'_`cutnum'_fv2'.png", replace
					
					// Third Threshold 
						twoway  (scatter `dv'_mean3 bin3 if tag3, msymbol(circle) msize(small) mcolor(black)) ///	
								(qfit `dv' `fv3' if `fv3' <0 , lwidth(medthick) lcolor(navy)) ///
								(qfit `dv' `fv3' if `fv3' >=0, lwidth(medthick) lcolor(navy)), ///
									leg(off) xline(0)	 ///
									xtitle("Average score centered at 2.5") ytitle("p(`dvtit')") caption("N = `n'") ///
									saving("${path}/Figures/Baseline Covariates/FGH/`dv'_2.5", replace)	
										
						graph export "${path}/Figures/Baseline Covariates/FGH/`dv'_`cutnum'_fv3'.png", replace
					
				restore
				
			end //Ends program baseline_fig

			// Creating Baseline Figures for Covariates
					baseline_fig tot_staff 			"Total Staff" 
					baseline_fig subsidy			"Subsidy Available" 
					baseline_fig scholarship		"Scholarship Available"
					baseline_fig sliding_fee		"Sliding Fee Scale Offered" 
					baseline_fig multi_discount		"Discount Available for Multiple Children" 
					baseline_fig capacity1			"Capacity" 
					baseline_fig enr_sub_total_1	"Subsidized Enrollment Total" 
					baseline_fig p_white_1			"% Subsidized Enrollment: White" 
					baseline_fig p_black_1			"% Subsidized Enrollment: Black" 
					baseline_fig p_hisp_1			"% Subsidized Enrollment: Hispanic" 
					baseline_fig p_asian_1			"% Subsidized Enrollment: Asian" 
					baseline_fig years_open 		"Number of Years Open" 
					baseline_fig family				"Family Homes"
					baseline_fig group				"Group Homes"
					baseline_fig dept_of_ed			"Dept of Ed Licensed"
					baseline_fig dept_of_hs			"Dept of Human Services Licensed"
			
			// Pulling Basic Descriptive Statistics for Each Covariate		
				loc covs "tot_staff subsidy scholarship sliding_fee multi_discount capacity1 enr_sub_total_1 p_white_1 p_black_1 p_hisp_1 p_asian_1 years_open family group dept_of_ed dept_of_hs"
					
					foreach x in `covs' {
					sum `x' if center==1 & nonmissing==1 
					sum `x' if center==0 & nonmissing==1 
					sum `x' if nonmissing==1 
					}
	
	
	
	