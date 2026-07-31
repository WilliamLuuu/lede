#!/usr/bin/env perl

use strict;
use warnings;

use Cwd qw(getcwd);
use File::Path qw(make_path);
use File::Spec;
use File::Temp qw(tempdir);
use FindBin;
use Test::More;

use lib "$FindBin::Bin/..";
use FeedOverlay qw(update_git_overlay);

my $root = tempdir(CLEANUP => 1);
my $source = File::Spec->catdir($root, "source");
my $build = File::Spec->catdir($root, "build");
my $package = File::Spec->catdir($source, "luci-app-openclash");
my $target = File::Spec->catdir(
	$build, "feeds", "luci", "applications", "luci-app-openclash"
);

make_path($package);
open(my $makefile, ">", File::Spec->catfile($package, "Makefile"))
	or die "Unable to create fixture Makefile: $!";
print {$makefile} "include \$(TOPDIR)/rules.mk\n";
close($makefile);

is(system("git", "init", "--initial-branch=dev", $source), 0, "initialize source repository");
is(system("git", "-C", $source, "config", "user.name", "Feed Overlay Test"), 0, "set git user name");
is(system("git", "-C", $source, "config", "user.email", "feed-overlay\@example.invalid"), 0, "set git user email");
is(system("git", "-C", $source, "add", "luci-app-openclash/Makefile"), 0, "stage fixture package");
is(system("git", "-C", $source, "commit", "-m", "Add fixture package"), 0, "commit fixture package");

make_path(File::Spec->catdir($build, "feeds", "luci", "applications"));
my $original_directory = getcwd();
chdir($build) or die "Unable to enter test build directory: $!";

is(
	update_git_overlay(
		"luci",
		"applications/luci-app-openclash",
		"$source;dev",
		"luci-app-openclash"
	),
	0,
	"install git overlay"
);

ok(-f File::Spec->catfile($target, "Makefile"), "package is generated under luci/applications");
ok(!-e File::Spec->catdir($build, "feeds", "openclash"), "standalone openclash feed is absent");
ok(
	!-e File::Spec->catdir($build, "feeds", "luci.tmp", "git-overlay"),
	"temporary overlay checkout is removed"
);

chdir($original_directory) or die "Unable to restore working directory: $!";
done_testing();
