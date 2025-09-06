---
title: "TLUG December 1998 Meeting"
date: "1998-12-01"
meetingType: "technical"
tags: ["meetings","legacy","technical"]
---

### Meeting picts
#### by A. Tomita

{{< meeting-gallery />}}

## December Meeting Information (Part 1)

<B>Date</B>: 12 December, 1998

<B>Meeting Time</B>: 12:30

<B>Talk</B>: Linux i18n/Japanization

<B>Meeting Place</B>:
*NEW VENUE*<BR>
Temple University<BR>
2-8-12 Minami Azabu, Minato-ku, Tokyo<BR>
(map at <A HREF="http://www.tuj.ac.jp/maps.html">
http://www.tuj.ac.jp/maps.html</A>)</TD></TR>

<TR><TD COLSPAN=2>
About 25 people gathered at one of Temple University Japan's large
classrooms for TLUG's December meeting.  Acting President Alberto Tomita
conducted the meeting.  After the important business of ordering and
consuming pizza, doing yet another SuSE installation on someone's
machine, and exploring the X server options on a notebook, we got
down to the featured talks.

<B>Stephen Turnbull</B> (U. Tsukuba) used a MagicPoint presentation to
describe the underpinnings of Linux internationalization (I18N),
localization (L10N), and multilingualization (M17N).  He explained
some of the issues involved in text input, output, and processing
that are a function of differing natural languages.  He emphasized
that following established standards and protocols for true I18N,
while a difficult path, is a much better (more general and more
likely to be adopted into mainstream Open Source projects) solution
than simply localizing an application.  He mentioned that we would be
able to read more on the subject in an upcoming article.
<P>
<B>Scott Stone</B> (PHT) outlined the practical methods available for
adapting an English Linux system to also support Japanese.  He
covered the various tools available for display, input processing,
and input methods under X (and the additional steps for getting a
Japanese console).  He discussed the languages and toolkits available
that provide international support, including Perl, Tcl/Tk, and with
several particularly optimistic words about the gtk toolkit.  A basic
theme of his talk was that it is quite practical to add Japanese to
an English system with today's Linux software.
<P>
For the question and answer session, Stephen and Scott were joined by
<B>Koji Ashiada</B> (PHT), who has recently been involved in porting
Applixware to the Japanese environment.  All three commented on the
POSIX locale scheme, and in particular the use of 'gettext' (now part
of glibc) to provide separate message catalogs for different natural
languages.
<P>
<A HREF="business.html">Part 2 - Business Meeting</A>
Important information about TLUG administration!
<P>
Report by <B>Jim Tittsler</B>, Tokyo   ICQ: 5981586
