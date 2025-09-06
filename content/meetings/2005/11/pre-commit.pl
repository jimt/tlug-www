#!/usr/local/bin/perl
#
# =========================================================================
# Copyright (c) 2004 and onwards, Twenty First Century Communications
# <swdev@tfcci.com>
#
# LICENCE:
#
#   This file is distributed under the terms of the BSD License (version
#   2). See the COPYING file, which should have been distributed with this
#   file, for details. If you did not receive the COPYING file, see:
#
#   http://www.jmglov.net/opensource/licenses/bsd.txt
#
# pre-commit
#
# DESCRIPTION:
#
#   Provides access control to paths and branches in the repository; ensures
#   that there are no DOS-style newlines; ensures that indenting is done with
#   spaces, not tabs; ensures that Perl modules have no shebang line; ensures
#   that Perl scripts have the correct shebang line
#
# USAGE:
#
#   Copy this script into the hooks/ subdirectory of the Subversion repository.
#
# DEPENDENCIES:
#
#   >= Perl 5.6.0
#   Subversion
#
# TODO:
#
#   - Nothing, this code is perfect
#
# MODIFICATIONS:
#
#   Josh Glover <jmglov@jmglov.net> (2004/06/01): Initial revision
# =========================================================================

use strict;
use warnings;

use File::Basename ();

use subs qw(fail log);

# Variable: @DESIGNER_MEMBERS
#
# List of users who are Designers

our @DESIGNER_MEMBERS = qw(abrown bwhite cdavis dsmith);

# Variable: @DESIGNER_PATHS
#
# Only users listed in <@DESIGNER_MEMBERS> can commit paths on the trunk
# listed in <@DESIGNER_PATHS>

our @DESIGNER_PATHS =
  (
   qr"^(trunk|branches/(PROD|QA)[^/]+)/appserver/Phoenix/Alarm.pm",
   qr"^(trunk|branches/(PROD|QA)[^/]+)/appserver/Phoenix/Object",
   qr"^(trunk|branches/(PROD|QA)[^/]+)/lib",
   qr"^(trunk|branches/(PROD|QA)[^/]+)/webserver/lib",
  ); # DESIGNER_PATHS[]

# Variable: $LOGFILE
#
# Hook logfile

our $LOGFILE = "/tmp/svn-hooks_pre-commit.log";

# Variable: $PL_SHEBANG
#
# The required shebang for Perl scripts

our $PL_SHEBANG = "#!/usr/local/bin/perl";

# Variable: @RELENG_BRANCHES
#
# Only users listed in <@RELENG_MEMBERS> can commit to branches listed
# in <@RELENG_BRANCHES>

our @RELENG_BRANCHES = qw(PROD);

# Variable: @RELENG_MEMBERS
#
# List of users who are Release Engineers

our @RELENG_MEMBERS = qw(cdavis dsmith);

# Variable: $SVNLOOK
#
# Path to Subversion's svnlook binary

our $SVNLOOK = "/usr/local/bin/svnlook";

# The first argument is the repository and the second is the transaction
our $REPOS = shift @ARGV or die "No repository argument (arg 1)!\n";
our $TXN   = shift @ARGV or die "No transaction argument (arg 2)!\n";

log "called with repository '$REPOS', transaction '$TXN'";

# Check args for tainting
if ($REPOS =~ /^([\w\s\(\)\[\]\-\/\.]+)$/) { $REPOS = $1 }
else { fail "Repository argument is bogus: $REPOS" }
### Josh Glover (2005/03/17): FSFS database backend uses different
###   transaction IDs; just don't validate the TXN parameter
#if ($TXN =~ /^([A-Za-z0-9]+)$/) { $TXN = $1 }
#else { fail "Transaction argument is bogus: $TXN" }
### Josh Glover (2005/03/17): FSFS database backend uses different
###   transaction IDs; just don't validate the TXN parameter

log "command-line arguments not tainted";

# Determine which files have been changed in this transaction
my @changed = split /\n/, `$SVNLOOK changed -t $TXN $REPOS`
  or fail "No files appear to have changed in transaction: $TXN";

log "files changed in this revision:\n".join( "\n", @changed );

my @files;
foreach my $line (@changed) {

  log $line;

  my @f = split /\s+/, $line;
  push @files, $f[1] unless $f[0] eq "D";

} # foreach (dealing with all but deleted files)

# Determine the author of this transaction
our $author;
chomp( $author = `$SVNLOOK author -t $TXN $REPOS` )
  or fail "Cannot determine author of transaction: $TXN";

log "author of this revision: $author";

# Loop through the files
foreach my $file (@files) {

  log "checking file: $file";

#  # De-taint $file
#  if ($file =~ /^([\w\s\(\)\[\]\-\/\.]+)$/) { $file = $1 }
#  else { fail "File is bogus: $file" }
#
#  log "file is not tainted: $file";

  # See if this is a designers-only path
  log "checking if '$file' is a designers-only path: ".
      join( " ", @DESIGNER_PATHS ).
      "; and if '$author' is a designer: ".
      join( " ", @DESIGNER_MEMBERS );
  fail( "Only Designers (". join( ", ", @DESIGNER_MEMBERS ).
       ") can commit to path:\n\n$file\n\n(you are '$author')" )
    if grep { $file =~ $_ } @DESIGNER_PATHS
      and not grep { $author eq $_ } @DESIGNER_MEMBERS;

  # See if this is a releng-only branch
  log "checking to see if '$file' is on a branch";
  if ($file =~ qr"^branches/([^/]+)/") {

    my $branch = $1;
    log "checking if '$branch' is a releng-only branch: ".
        join( " ", @RELENG_BRANCHES ).
        "; and if '$author' is a release engineer: ".
        join( " ", @RELENG_MEMBERS );
    fail( "Only Release Engineers (". join( ", ", @RELENG_MEMBERS ).
         ") can commit to branch:\n\n$branch\n\n".
         "(you tried to commit file '$file' and you are '$author'" )
      if grep { $branch =~ /^$_/ } @RELENG_BRANCHES
        and not grep { $author eq $_ } @RELENG_MEMBERS;

  } # if (checking releng restrictions)

  else { log "'$file' is not on a branch" }

  # Everything below this point is a content check, so exclude binary files
  next if $file =~ /\.(gif|gz|jar|jpg|jpeg|svgz|sx(c|i|w)|pdf|png|ppt|tiff|tgz|vsd|zip)$/;

  # No file may have a ^M at the end of a line!
  log "checking '$file' for DOS-style newlines";
  chomp( my $num = `$SVNLOOK cat -t $TXN $REPOS $file | grep -c '
' 2>/dev/null` );
  fail "File '$file' contains $num lines with DOS-style newlines (^M)!"
    if $num;

  # Check files that cannot contain tabs
  if ($file =~ /\.(cgi|pl|pm|sh|sql|tmpl)$/) {

    log "checking '$file' for tabs";
    chomp( my $num = `$SVNLOOK cat -t $TXN $REPOS $file | grep -c '	' 2>/dev/null` );

    fail "File '$file' contains $num lines with tabs!" if $num;

  } # if (checking for tabs)

  # Perl modules need no shebang line
  if ($file =~ /\.pm$/) {

    log "'$file' is a Perl module, making sure it does not have a shebang";
    fail "File '$file' is a Perl module, but it starts with a shebang!"
      if `$SVNLOOK cat -t $TXN $REPOS $file | head -1 | grep '^#!' 2>/dev/null`;

  } # if (found a shebang line)

  # Perl scripts must use the /usr/local/bin/perl interpreter
  if ($file =~ /\.(cgi|pl)$/) {

    log "'$file' is a Perl script, making sure the shebang is $PL_SHEBANG";
    fail( "File '$file' is a Perl script, but it starts with this line:\n\n".
         `$SVNLOOK cat -t $TXN $REPOS $file | head -1`.
         "\nIt must be:\n\n$PL_SHEBANG" )
      unless `$SVNLOOK cat -t $TXN $REPOS $file | head -1 | grep '^$PL_SHEBANG' 2>/dev/null`;

  } # if (bad shebang)

  log "file is OK: $file";

} # foreach (processing each file)

# Victory!
log "transaction is OK";
exit;


# Subroutine: fail()
#
# Causes the commit to fail with the specifed error message.
#
# Parameters:
#
#   msg - error message (no need for a newline at the end)

sub fail {

  my $msg = (shift or "Unknown error!");

  log $msg;

  die( "\n\nYour commit failed for the following reason:\n".
       "------------------------------------------------------------\n".
       "$msg\n".
       "------------------------------------------------------------\n\n" );

} # fail()


# Subroutine: log()
#
# Logs the specified message.
#
# Parameters:
#
#   msg - log message (no need for a newline at the end)

sub log {

  my $msg = shift;

  # No need to do anything if no log message was specified
  return unless defined $msg;

  # Prepend the timestamp and script name, and the transaction,
  # repository, and author if we know any of them
  my $preface = "";
  my $repos   = $REPOS;
  my $me      = File::Basename::basename( $0 );
  $repos      =~ s"^.+/([^/]+)$"$1";
  my @time    = localtime;
  $preface   .= sprintf( "%02d:%02d:%02d",
                         $time[2], $time[1], $time[0] );
  $preface   .= " $me: ";
  $preface   .= "$repos:"    if $repos;
  $preface   .= "$TXN "      if $TXN;
  $preface   .= "[$author] " if $author;

  # Append a newline if necessary
  $msg .= "\n" unless $msg =~ /\n$/;

  # Open the logfile
  open LOG, ">>$LOGFILE" or return;

  # Log the message
  print LOG "$preface$msg";

  # Close the logfile
  close LOG or return;

} # log()
