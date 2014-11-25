#!/usr/bin/perl

my %programmes = (
	'volumeicon' => 'volumeicon &',
	'compton'	=>	'compton -bCG -o 0.38 -O 200 -I 200 -t 0 -l 0 -r 3 -D2 -m 0.88 &',
	'wicd-client' => 'wicd-client -t&',
	'fcitx' => 'fcitx -d &',
	'launchy' => 'launchy &',
	'autossh' => 'autossh -M 20000 -D 9050 -CnN antigfw\@vps &',
	'EvernoteTray' => 'wine  "/home/hacksign/.wine/drive_c/Program Files/Evernote/Evernote/EvernoteTray.exe"&',
);
foreach my $key(keys %programmes){
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
