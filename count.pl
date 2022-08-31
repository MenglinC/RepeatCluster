#!perl
open (MARK, "< Hs_repeat_subfamily.txt") or die "can not open it!";
while ($line = <MARK>){
		print($line);
		chomp($line);
		print($line);
		system_call("awk \'\$4==\"".$line."\"\'   /home/xxzhang/workplace/project/geneRegion/repeat_interest.bed |sed 's\/\\s\\+\/\\t\/g' |bgzip -c >./subfamily/Hs_".$line.".bed.gz");
		system_call("time giggle search -i split_sort_b -q ./subfamily/Hs_".$line.".bed.gz -s >./giggle_result/Hs_".$line.".bed.gz.giggle.result");
		system_call("python /home/xxzhang/workplace/software/giggle/scripts/giggle_heat_map.py  -t \"".$line."\" -s /home/xxzhang/workplace/software/giggle/examples/rme/states.txt -c /home/xxzhang/workplace/software/giggle/examples/rme/EDACC_NAME.txt -i ./giggle_result/Hs_".$line.".bed.gz.giggle.result -o ./pdf_result/Hs_".$line.".bed.gz.3x11.pdf -n /home/xxzhang/workplace/software/giggle/examples/rme/new_groups.txt --x_size 3 --y_size 11 --stat combo --ablines 15,26,31,43,52,60,72,82,87,89,93,101,103,116,120,122,127 --state_names /home/xxzhang/workplace/software/giggle/examples/rme/short_states.txt --group_names /home/xxzhang/workplace/software/giggle/examples/rme/new_groups_names.txt");
} 
close(MARK);

sub system_call
{
  my $command=$_[0];
  print "\n\n".$command."\n\n";
  system($command);
}
