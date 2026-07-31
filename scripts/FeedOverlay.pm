package FeedOverlay;

use strict;
use warnings;

use Exporter qw(import);
use File::Basename qw(dirname);
use File::Copy qw(move);
use File::Path qw(make_path remove_tree);

our @EXPORT_OK = qw(update_git_overlay);

sub update_git_overlay {
	my ($feed, $destination, $src, $source_directory) = @_;
	my ($url, $branch) = split(/;/, $src, 2);
	my $overlay_root = "./feeds/$feed.tmp/git-overlay";
	my $checkout = "$overlay_root/checkout";
	my $source = "$checkout/$source_directory";
	my $target = "./feeds/$feed/$destination";
	my $target_parent = dirname($target);

	remove_tree($overlay_root);
	make_path($overlay_root) or do {
		warn "Unable to create git overlay directory '$overlay_root'\n";
		return 1;
	};

	my @clone = ("git", "clone", "--depth", "1");
	push @clone, ("--branch", $branch) if $branch;
	push @clone, ($url, $checkout);

	warn "Updating git overlay '$feed/$destination' from '$src/$source_directory' ...\n";
	if (system(@clone) != 0) {
		remove_tree($overlay_root);
		return 1;
	}

	if (!-d $source) {
		warn "Git overlay source directory '$source_directory' does not exist in '$src'\n";
		remove_tree($overlay_root);
		return 1;
	}

	if (-d $target) {
		remove_tree($target);
	} elsif (-e $target || -l $target) {
		unlink($target) or do {
			warn "Unable to remove existing git overlay target '$target'\n";
			remove_tree($overlay_root);
			return 1;
		};
	}

	if (!-d $target_parent) {
		make_path($target_parent) or do {
			warn "Unable to create git overlay target parent for '$target'\n";
			remove_tree($overlay_root);
			return 1;
		};
	}

	move($source, $target) or do {
		warn "Unable to install git overlay into '$target': $!\n";
		remove_tree($overlay_root);
		return 1;
	};

	remove_tree($overlay_root);
	return 0;
}

1;
