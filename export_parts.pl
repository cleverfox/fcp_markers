#!/usr/bin/perl
use v5.10;
use Mojo::DOM;
use Mojo::File 'path';
use Mojo::Util;

$xml = path($ARGV[0])->slurp;
my $dom = Mojo::DOM->new($xml);
my $markers={};
$dom->find('chapter-marker')->each(sub {
		#say($_);
		my $s;
		if($_->{start}=~/(\d+)\/(\d+)s$/){
			$s=int($1/$2);
		}elsif($_->{start}=~/(\d+)s$/){
			$s=int($1);
		};
		$markers->{$s}=$_->{value};
	});
$dom->find('marker')->each(sub {
		my $s;
		if($_->{start}=~/(\d+)\/(\d+)s$/){
			$s=int($1/$2);
		}elsif($_->{start}=~/(\d+)s$/){
			$s=int($1);
		};
		$markers->{$s}=1;
	});
my @parts;
my $start;
my $name;
foreach(sort { $a <=> $b } keys %$markers){
	if($start){
		push(@parts,[$start,$_,$name]);
	}
	
	if($markers->{$_} eq '1'){
		$start=0;
	}else{
		$start=$_;
		$name=$markers->{$_}
	}
	#say("#",$_, " ",$markers->{$_});
}
foreach(@parts){
	printf("ffmpeg -ss %d -i full.mp4 -c copy -t %d \"parts/%s.mp4\"\n",
		($_->[0]-1),($_->[1]-$_->[0]+2),$_->[2]);
}
