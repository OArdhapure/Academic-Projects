* Step 1: Importing dataset;

data Income;
	infile '"/home/u58698825/BAN 110/Project/adult.data' dsd dlm=',' truncover;
	input age workclass & $20. fnlwgt education & $20. education_num 
		marital_status & $20. occupation & $20. relationship & $20. race & $20. sex $
  		  capital_gain capital_loss hours_per_week native_country $
  		  Annual_Income $;
run;

* step 2: Checking descriptive stats of the dataset;

title "Checking Character Values";

proc contents varnum data=income;
run;

proc freq data=income;
	tables workclass education marital_status occupation relationship race sex 
		native_country Annual_Income;
run;

title "Checking Numeric Values";

proc univariate data=income;
	var _numeric_;
run;

proc means data=income n nmiss mean max min;
	var _numeric_;
run;

proc sgplot data=income;
	histogram capital_gain;
	density capital_gain;
	density capital_gain / type=kernel;
run;

proc sgplot data=income;
	histogram capital_loss;
	density capital_loss;
	density capital_loss / type=kernel;
run;

proc sgplot data=income;
	histogram hours_per_week;
	density hours_per_week;
	density hours_per_week / type=kernel;
run;



*step 3: checking missing values;

title "Checking Missing Character Values";

Proc format;
	value $count_missing ' '='missing' other='Nonmissing';
run;

proc freq data=income;
	tables _character_ / nocum missing;
	format _character_  $count_missing.;
run;

* step 4: cleaning the dataset_removing invalid values from categorical variables;

title"Treating invalid and missing values in categorical variables";

data clean_income;
	set income;
	file print;

	if missing(workclass) then
		delete;

	if workclass='?' then
		workclass="NA";

	if occupation='?' then
		occupation="NA";

	if native_country='?' then
		native_country="NA";
run;

proc freq data=clean_income;
	table workclass occupation native_country ;
run;

*step 5: Cleaning dataset_checking errors in numerical variable;

title"Initial Dataset";
proc means data=income n nmiss mean median min max;
	var _numeric_;
run;

title"Clean Dataset";
proc means data=clean_income n nmiss mean median min max;
	var _numeric_;
run;

title"checking errors in numerical variable";

proc sgplot data=clean_income;
	histogram age;
	density age;
	density age / type=kernel;
run;

proc sgplot data=clean_income;
	histogram fnlwgt;
	density fnlwgt;
	density fnlwgt / type=kernel;
run;

proc sgplot data=clean_income;
	histogram education_num;
	density education_num;
	density education_num / type=kernel;
run;

*step 6: cleaning dataset_Transforming hours per week & native_country variable;

title"Transforming hours per week & native_country variable";

proc means data=clean_income;
	var hours_per_week;
run;

proc sgplot data=clean_income;
	histogram hours_per_week;
	density hours_per_week;
	density hours_per_week / type=kernel;
run;

proc univariate data=clean_income;
	var hours_per_week;
run;

data clean_income_category;
	set clean_income;
	length native_region $15.;

	if hours_per_week < 40 then
		hours_per_week_category="Less than 40 Hours";
	else if hours_per_week ge 40 and hours_per_week le 45 then
		hours_per_week_category="40 to 45 Hours";
	else if hours_per_week gt 45 and hours_per_week le 60 then
		hours_per_week_category="45 to 60 Hours";
	else if hours_per_week gt 60 and hours_per_week le 80 then
		hours_per_week_category="60 to 80 Hours";
	else if hours_per_week gt 80 then
		hours_per_week_category="More than 80 Hours";

	if native_country in ('Cambodia', 'China', 'Hong', 'Laos', 'Thailand', 
		'Japan', 'Taiwan', 'Vietnam') than native_region="Asia_East";
	else if native_country in ('India', 'Iran') than native_region="Asia_Central";
	else if native_country in ('Cuba', 'Guatemal', 'Jamaica', 'Nicaragu', 
	'Puerto-R', 'Dominica', 'El-Salva', 'Haiti', 'Honduras', 'Mexico', 'Trinadad') 
	than native_region="Central_America";
	else if native_country in ('Ecuador', 'Peru', 'Columbia') than 
	native_region="South_America";
	else if native_country in ('United-S', 'Canada') than 
	native_region="North_America";
	else if native_country in ('England', 'Germany', 'Holand-N', 'Ireland', 
	'France', 'Greece', 'Italy', 'Portugal', 'Scotland') than 
	native_region="Europe_West";
	else if native_country in ('Poland', 'Yugoslav', 'Hungary') than 
	native_region="Europe_East";
	else if native_country in ('NA', 'South') than native_region="NA";
	else if native_country in ('Philippi') than native_region="Asia_SouthEast";
	else if native_country in ('Outlying') than native_region="Outlying-US";
	
run;

proc print data=clean_income_category (obs=10);
run;

proc freq data=clean_income_category;
	table hours_per_week_category native_region;
run;

* step 7: cleaning dataset_ckecking errors in capital gain & loss;

title"ckecking errors in capital gain & loss";

proc means data=clean_income;
	var capital_gain capital_loss;
run;

proc sgplot data=clean_income;
	histogram capital_gain;
	density capital_gain;
	density capital_gain / type=kernel;
run;

proc univariate data=clean_income;
	var capital_gain capital_loss;
run;

proc sgplot data=clean_income;
	histogram capital_loss;
	density capital_loss;
	density capital_loss / type=kernel;
run;

*step 8: cleaning dataset_removing zero values from capital gain & capital loss;

title"removing zero values from capital gain & capital loss";

data clean_income_capital_nonzero;
	set clean_income_category;
	array n{*} capital_gain capital_loss;

	do i=1 to dim(n);

		if n{i}=0 then
			call missing(n{i});
	end;
	drop i;
run;

proc print data=clean_income_capital_nonzero (obs=10);
run;


*step 9: cleaning dataset_revised data for capital gain & capital loss;

title"revised data for capital gain & capital loss";

proc means data=clean_income_capital_nonzero;
	var capital_gain capital_loss;
run;

proc sgplot data=clean_income_capital_nonzero;
	hbox capital_gain;
run;

proc sgplot data=clean_income_capital_nonzero;
	hbox capital_Loss;
run;

proc sgplot data=clean_income_capital_nonzero;
	histogram capital_gain;
	density capital_gain;
	density capital_gain / type=kernel;
run;

proc sgplot data=clean_income_capital_nonzero;
	hbox capital_loss;
run;

proc sgplot data=clean_income_capital_nonzero;
	histogram capital_loss;
	density capital_loss;
	density capital_loss / type=kernel;
run;

proc univariate data=clean_income_capital_nonzero;
	var capital_gain capital_loss;
run;

* step 10: cleaning dataset_transforming capital gain & capital loss;

title"transforming capital gain & capital loss";

data clean_income_capital;
	set clean_income_capital_nonzero;
	length capital_gain_category $15.;
	length capital_loss_category $15.;

	if missing(capital_gain) then
		capital_gain_category="None";
	else if capital_gain <=3411 then
		capital_gain_category="Low";
	else if capital_gain > 3411 and capital_gain <=14084 then
		capital_gain_category="Medium";
	else if capital_gain >=14084 and capital_gain < 99999 then
		capital_gain_category="High";
	else if capital_gain = 99999 then
		capital_gain_category="Very High";

	if missing(capital_loss) then
		capital_loss_category="None";
	else if capital_loss <=1672 then
		capital_loss_category="Low";
	else if capital_loss > 1672 and capital_loss <=1977 then
		capital_loss_category="Medium";
	else if capital_loss >=1977 then
		capital_loss_category="High";
run;

proc print data=clean_income_capital (obs=10);
run;

proc freq data=clean_income_capital;
	table capital_gain_category capital_loss_category;
run;


*step 11: cleaning dataset_ckecking for outliers in capital gain & capital Loss;

proc sgplot data=clean_income_capital;
	hbox capital_gain;
run;

proc sgplot data=clean_income_capital;
	histogram capital_gain;
	density capital_gain;
	density capital_gain / type=kernel;
run;

proc sgplot data=clean_income_capital;
	hbox capital_loss;
run;

proc sgplot data=clean_income_capital;
	histogram capital_loss;
	density capital_loss;
	density capital_loss / type=kernel;
run;

* Step 12 : ckecking outliers in capital_gain;
title"Outlier detection step for capital_gain";

proc means data=clean_income_capital noprint;
	var capital_gain;
	output out=Mean_Std_A1(drop=_type_ _freq_) mean=std= / autoname;
run;

title "Outliers for capital_gain Based on 2 * Standard Deviations";

data _null_;
	file print;
	set clean_income_capital;

	if _n_=1 then
		set Mean_Std_A1;

	if capital_gain lt capital_gain_Mean - 2*capital_gain_StdDev and not 
		missing(capital_gain) or capital_gain gt 
		capital_gain_Mean + 2*capital_gain_StdDev then
			put capital_gain _n_;
run;

title "Outliers Based on Interquartile Range";

proc means data=clean_income_capital noprint;
	var capital_gain;
	output out=Tmp Q1=Q3=QRange= / autoname;
run;

data _null_;
	file print;
	set clean_income_capital;

	if _n_=1 then
		set Tmp;

	if capital_gain le capital_gain_Q1 - 1.5*capital_gain_QRange and not 
		missing(capital_gain) or capital_gain ge 
		capital_gain_Q3 + 1.5*capital_gain_QRange then
			put capital_gain _n_;
run;

* Step 13 : ckecking outliers in capital_loss;
title"Outlier detection step for capital_loss";

proc means data=clean_income_capital noprint;
	var capital_loss;
	output out=Mean_Std_A1(drop=_type_ _freq_) mean=std= / autoname;
run;

title "Outliers for capital_gain Based on 2 * Standard Deviations";

data _null_;
	file print;
	set clean_income_capital;

	if _n_=1 then
		set Mean_Std_A1;

	if capital_loss lt capital_loss_Mean - 2*capital_loss_StdDev and not 
		missing(capital_loss) or capital_loss gt 
		capital_loss_Mean + 2*capital_loss_StdDev then
			put capital_loss _n_;
run;

title "Outliers Based on Interquartile Range";

proc means data=clean_income_capital noprint;
	var capital_loss;
	output out=Tmp Q1=Q3=QRange= / autoname;
run;

data _null_;
	file print;
	set clean_income_capital;

	if _n_=1 then
		set Tmp;

	if capital_loss le capital_loss_Q1 - 1.5*capital_loss_QRange and not 
		missing(capital_loss) or capital_loss ge 
		capital_loss_Q3 + 1.5*capital_loss_QRange then
			put capital_loss _n_;
run;

*step 15: Final Dataset;

data Cleaned_Income;
	set clean_income_capital;
run;

title"Cleaned Dataset";
proc print data=cleaned_income (obs=10);
run;

*step 14: Exporting Dataset;

proc export data=cleaned_income 
		outfile="/home/u58698825/BAN 110/Project/cleaned_income.xlsx" dbms=xlsx 
		replace label;
	sheet="income";
run;




