#
# Copyright 2015-2016 Gary R. Van Sickle (grvs@users.sourceforge.net).
#
# This file is part of UniversalCodeGrep.
#
# UniversalCodeGrep is free software: you can redistribute it and/or modify it under the
# terms of version 3 of the GNU General Public License as published by the Free
# Software Foundation.
#
# UniversalCodeGrep is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# UniversalCodeGrep.  If not, see <http://www.gnu.org/licenses/>.


# Determine the number of elements in an array.
function alen (a, i, i_max)
{
	i_max = 0
	for (i in a)
	{
		###print("i=", i)
		if (i+0 > i_max+0) i_max=i
	}
	return i_max+0
}

function adelete(a,    i)
{
	# Delete all entries in array a.
	for (i in a)
	{
    	delete a[i]
    }
}

# Copy a numerically-indexed array
function acopy(ain, aout,    i)
{
	# Make sure aout is empty.
	adelete(aout)
    
	for (i=1; i <= alen(ain); i++ )
	{
		###print("acopy: ", i, ain[i])
	    aout[i] = ain[i];
    }
    
    return 0
}

# Return a count of the number of lines in the given text file.
function line_count(filename,	cmd_line, retval)
{
	retval=0;
	cmd_line=("cat " filename " | tail -n +3 | wc -l");
	while((cmd_line | getline retval) > 0)
	{
		# Keep reading.
	}
	close(cmd_line);
	return retval;
}


BEGIN {
	if(ARGC != 4)
	{
		print("Incorrect number of args: ", ARGC)
		exit 1
	}

	NUM_ITERATIONS=10;
	RESULTS_FILE=ARGV[2];
	BOOST_PATH=ARGV[3];
	
	cur_line=0
	while(getline < ARGV[1])
	{
		cur_line++;
		CMD_LINE_ARRAY[cur_line]=$0;
		#print "cur_line=", cur_line, $0
	}
	close(ARGV[1])
	
	print("Starting performance tests, results file is", RESULTS_FILE);
	
	for(i=1; i<=alen(CMD_LINE_ARRAY); ++i)
	{
		COMMAND_LINE=CMD_LINE_ARRAY[i];
		
		# "Prep" run, to eliminate disk cache variability and capture the matches.
		# We pipe the results through sort so we can diff these later.
		print("Timing: ", COMMAND_LINE) >> RESULTS_FILE;
		PREP_RUN_FILES[i]=("SearchResults_" i ".txt");
		wrapped_cmd_line=("{ " COMMAND_LINE " 2>>" PREP_RUN_FILES[i] " ; } 3>&1 4>&2 | sort >> " PREP_RUN_FILES[i] ";");
		print("Prep run for wrapped command line: '" wrapped_cmd_line "'") > PREP_RUN_FILES[i];
		system(wrapped_cmd_line);
		###print(wrapped_cmd_line);
		close(PREP_RUN_FILES[i]);
	
		# Timing runs.
		TIME_RESULTS_FILE=("./time_results_" i ".txt");
		wrapped_cmd_line=("{ " COMMAND_LINE " 2>>" TIME_RESULTS_FILE " ; } 3>&1 4>&2;");
		print("Timing run for wrapped command line: '" wrapped_cmd_line "'") > TIME_RESULTS_FILE;
		for(ITER=1; ITER <= NUM_ITERATIONS; ++ITER)
		{
			# Do a single run.
			system(wrapped_cmd_line);
			###print(wrapped_cmd_line);
		}
		
		# Retrieve the timing data.
		adelete(REAL_TIME);
		REAL_TIME[1]=0;
		NUM_TIMES=0;
		while((getline < (TIME_RESULTS_FILE)) > 0)
		{
			if($1 == "real")
			{
				NUM_TIMES += 1;
				REAL_TIME[NUM_TIMES] += $2;
				print("Time entry: " REAL_TIME[NUM_TIMES]) >> RESULTS_FILE;
			}
		}
		if(NUM_TIMES > NUM_ITERATIONS)
		{
			print("ERROR: Too many time entries: " NUM_TIMES);
			exit 1;
		}
		close(TIME_RESULTS_FILE);
	
		# Determine the average.
		AVG_TIME[i]=0;
		SAMPLE_STD_DEV[i]=0;
		SEM[i]=0;
		for (j=1; j <= alen(REAL_TIME); ++j)
		{
			ELAPSED=REAL_TIME[j];
			AVG_TIME[i]=(AVG_TIME[i] + ELAPSED);
		}
		AVG_TIME[i]=(AVG_TIME[i] / NUM_ITERATIONS);
		# Calculate the sample std deviation and the standard error of the mean (SEM).
		# https://en.wikipedia.org/wiki/Standard_error#Standard_error_of_the_mean
		for(j=1; j <= alen(REAL_TIME); ++j)
		{
			# sample std dev is sqrt((sum of squared deviations from mean)/(N-1))
			SAMPLE_STD_DEV[i] += (AVG_TIME[i] - REAL_TIME[j])^2;
		}
		SAMPLE_STD_DEV[i] = sqrt(SAMPLE_STD_DEV[i]/(NUM_TIMES-1));
		SEM[i] = SAMPLE_STD_DEV[i]/sqrt(NUM_TIMES);
		print("Average elapsed time      :", AVG_TIME[i]) >> RESULTS_FILE;
		print("Sample stddev             :", SAMPLE_STD_DEV[i]) >> RESULTS_FILE;
		print("Standard Error of the Mean:", SEM[i]) >> RESULTS_FILE;
	}
	
	# Determine any differences in the outputs.
	# Use the grep results (last) as the standard.
	GREP_OUT_INDEX=alen(CMD_LINE_ARRAY);
	GOLD_STD_FILE=(PREP_RUN_FILES[GREP_OUT_INDEX])
	for(i=1; i<=alen(CMD_LINE_ARRAY); ++i)
	{
		NUM_MATCHED_LINES[i]=line_count(PREP_RUN_FILES[i]);
	}
	
	# Output the results.
	print("| Program | Avg of", NUM_ITERATIONS, "runs | Sample Stddev | SEM | Num Matched Lines |") >> RESULTS_FILE;
	print("|---------|----------------|---------------|-----|-------------------|") >> RESULTS_FILE;
	for(i=1; i<=alen(CMD_LINE_ARRAY); ++i)
	{
		print("|", CMD_LINE_ARRAY[i], "|", AVG_TIME[i], "|", SAMPLE_STD_DEV[i], "|", SEM[i], "|", NUM_MATCHED_LINES[i], "|") >> RESULTS_FILE;
	}
}