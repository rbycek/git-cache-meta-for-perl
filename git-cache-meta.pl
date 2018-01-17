#! /usr/bin/perl -w
use strict;
use warnings;
my ($operation, $git_cache_meta_file) = @ARGV;
my $help = "Usage:\t$0 --store (metadata file)|--stdout|--apply (metadata file)\n\tDefault metadata file is \".git_cache_meta\"\n\t--apply should probably be run through sudo\n\n";
if (defined $operation) {
        if (not defined $git_cache_meta_file) {
        $git_cache_meta_file = ".git_cache_meta";
        }
        if ( $operation eq '--store' || $operation eq '--stdout' ) {
        if (  $operation eq '--store' ){
                unlink $git_cache_meta_file;
        }
                open my $git_ls,'-|','git ls-files';
                while (my $filename = <$git_ls>) {
                        chomp ($filename);
                        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
                        my @months = ("01","02","03","04","05","06","07","08","09","10","11","12");
                        my ($sec,$min,$hour,$day,$month,$year) = (localtime($mtime))[0,1,2,3,4,5];
                        my $fullyear = $year + 1900;
                        if (  $operation eq '--store' ){

                                open(my $fh,'>>', $git_cache_meta_file );
                                printf $fh "chown $uid \"$filename\"\n";
                                printf $fh "chgrp $gid \"$filename\"\n";
                                printf $fh "touch -c -d \"$fullyear-$months[$month]-$day $hour\:$min\:$sec\" \"$filename\"\n";
                                printf $fh "chmod %04o \"$filename\"\n", $mode & 07777;
                                close $fh;
                        }
                        else {
                                printf "chown $uid \"$filename\"\n";
                                printf "chgrp $gid \"$filename\"\n";
                                printf "touch -c -d \"$fullyear-$months[$month]-$day $hour\:$min\:$sec\" \"$filename\"\n";
                                printf "chmod %04o \"$filename\"\n", $mode & 07777;
                        }
                }
                close $git_ls;

        }
        elsif ($operation eq '--apply') {
		system("chmod +x $git_cache_meta_file");
		system("sh $git_cache_meta_file");	

        }
        else {
                die $help;
        }
}
else {
        die $help;
}
