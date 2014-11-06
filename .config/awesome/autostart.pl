#!/usr/bin/perl

my %programmes = (
	'volumeicon' => 'volumeicon &',
	'xcompmgr' => 'xcompmgr -cCfF -r7 -o.65 -l-10 -t-8 -D1 &',
	'wicd-gtk' => 'wicd-gtk -t&',
	'fcitx' => 'fcitx -d &',
	'launchy' => 'launchy &',
	'EvernoteTray' => 'wine  "/home/hacksign/.wine/drive_c/Program Files/Evernote/Evernote/EvernoteTray.exe"&',
	'autossh' => 'autossh -M 20000 -D 9050 -CnN antigfw\@www.hacksign.cn -f&'
);
foreach my $key(keys %programmes){
	system($programmes{$key}) if `pgrep $key|wc -l` == 0;
}
