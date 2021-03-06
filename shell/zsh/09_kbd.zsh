local kbd_conf_dir kbd_conf_file kbd_custom_script kbd_original_script

autoload colors; colors;

kbd_conf_dir=${ZDOTDIR:-$HOME}/.zkbd
[[ -d $kbd_conf_dir ]] || mkdir $kbd_conf_dir || return 1

kbd_conf_file=$kbd_conf_dir/$TERM-${DISPLAY:-$VENDOR-$OSTYPE}
kbd_custom_script=$kbd_conf_dir/zkbd.tmp

if [ ! -f $kbd_conf_file ]
then
  cat <<-EOF
	This zsh setup uses a mapping between the key pressed and key sequence, for example : key[Up]='^[[A'
	${fg[green]}pro${reset_color} : changing term / OS / whatever is easy.
	${fg[red]}con${reset_color} : for each new setup, you have to fill in a new file.

	This job is done by the current script : you will be prompted to type near ${fg_bold[red]}100${reset_color} keys / keys with modifiers. It will take some minutes but the generated file is mandatory for key bindings.

	${bold_color}You can also skip this step by pressing ctrl+C${reset_color}, but you will only have minimalist bindings.

	No zkbd file found ($kbd_conf_file), creating one...
	EOF


  # the default zkbd script doesn't allow me to choose which modifiers I want.
  # I copy the script, change some values, and run it.

  kbd_original_script=$(findFileInFpath zkbd)

  if [ -z $kbd_original_script ]
  then
    print "\n\n${fg[red]}Can't find the zkbd script !$reset_color you will need it to create key bindings.\n"
  else
    # want shift, control and alt in the modifiers
    # and want the modifiers to be used
    sed -r 's/modifiers=.*/modifiers=(Shift- Control- Alt- # Meta-/;
    s/for key in \$pckeys/for key in $pckeys $^modifiers$^pckeys/' $kbd_original_script > $kbd_custom_script
    zsh -f $kbd_custom_script
    [ ! $? = 0 ] && print "\n\n${fg[red]}file $kbd_conf_file not created !$reset_color you will need it to use key bindings.\n"
    rm $kbd_custom_script
    find $kbd_conf_dir -name '*tmp' -delete
  fi
fi

[ -f $kbd_conf_file ] && source $kbd_conf_file

unset  kbd_conf_dir kbd_conf_file kbd_custom_script kbd_original_script
