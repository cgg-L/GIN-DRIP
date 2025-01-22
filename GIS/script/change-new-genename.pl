use strict;
use warnings;
use Getopt::Long;

############
##Parameter
############
my $opt_help;
my $input;
my $column;

GetOptions("help|h"  => \$opt_help,
	"input|input=s" => \$input,
	"column|column=f" => \$column,
);

&usage() if $opt_help;

die "-input is not provided!\n" if !$input;

##############

my %hash;
my %hash2;
my %hash3;

open IN1, "<./database/HGNC/hgnc_complete_set.txt" or die "Open summary file failed!\n" ;

# 1,2,6,7,9
#1 HGNC ID
#2 Approved Symbol

#6 Locus Group
#7 Previous Symbols
#9 Synonyms

# 1,2,4,9,11

while(my $line=<IN1>)
{
	chomp($line);
	my @f = split(/\t/, $line);

	my $hgnc_id = $f[0];
	my $symbol = $f[1];
	my $locus_group  = $f[3];
	$locus_group =~ s/ /\-/g;

	my $alias_symbol = $f[8];
	my $prev_symbol = $f[10];

	$hash{$symbol} = $locus_group;

	if ($alias_symbol ne "")
	{	
		$alias_symbol =~ s/"//g;

		my @genename=split(/\|/,$alias_symbol);
		$hash2{$symbol}= join("\t",@genename);
	}

	if ($prev_symbol ne "")
	{	
		
		$prev_symbol =~ s/"//g;

		my @genename=split(/\|/,$prev_symbol);
		$hash3{$symbol}= join("\t",@genename);
	}
	
}

close IN1;


open IN2, "<$input" || die();
#open OUT1, ">$input.hgnc" || die();
while(my $line=<IN2>)
{
	chomp($line);
	next if $line !~ /\S+/;

	my @f = split(/\t/, $line);

	my $flag=0;

	if(exists $hash{$f[0]})
	{
		print join("\t","Approved-Symbol",$f[0],$hash{$f[0]},@f)."\n";
		$flag=1;
	}
	else
	{
		foreach (keys %hash2)
		{
			my $value=$hash2{$_};
			my @genename = split(/\t/, $value);
	
			for(my $i=0;$i<@genename;$i++)
			{
				if($f[0] eq $genename[$i])
				{
					print join("\t","Alias_Symbol",$_,$hash{$_},@f)."\n";

					$flag=1;
					last;
				}
			}
			#if ($flag==1) 
			#{
				#last;
			#}
		}
		#if ($flag==1) 
		#{
		#	next;
		#}
		foreach (keys %hash3)
		{
			my $value=$hash3{$_};
			my @genename = split(/\t/, $value);
	
			for(my $i=0;$i<@genename;$i++)
			{
				if($f[0] eq $genename[$i])
				{
					print join("\t","Prev_Symbol",$_,$hash{$_},@f)."\n";
					$flag=1;

					last;
				}
			}
			#if ($flag==1) 
			#{
			#	last;
			#}			
		}

	}

	if($flag==0){print join("\t","failed",$f[0],"NA",@f)."\n";}
}
close IN2;
#close OUT1;




sub usage()
{
		
	print "\n*******************************************************\n";	
	print "*************************\n";

	print "\n*** The script was complied on Mar 9 2021 15:21:20 ***\n";
	######

	print "\n\trun :\n";
	print "\t\tExample 1.1: change-new-genename.pl -input * |less \n";
	
	####
	print "\n*************************\n";
	print "*******************************************************\n\n";	

	exit(0);
}

