#!/bin/bash
# Export current xrandr display settings as a shell command
S_LOOKING_FOR_DISPLAY=0
S_GOT_DISPLAY=1

cmd="xrandr"
state=$S_LOOKING_FOR_DISPLAY
while read line; do
    tokens=( $line )
    if [ $state == $S_LOOKING_FOR_DISPLAY ] && [ ${tokens[1]} == "connected" ]; then
        state=$S_GOT_DISPLAY
        cmd="$cmd --output ${tokens[0]}"

        i=0
        if [ ${tokens[2]} == "primary" ]; then
            i=1
            cmd="$cmd --primary"
        fi

        pos_x=$(cut -d"+" -f2 <<< ${tokens[((2+i))]})
        pos_y=$(cut -d"+" -f3 <<< ${tokens[((2+i))]})
        cmd="$cmd --pos ${pos_x}x${pos_y}"

        rotate="${tokens[((3+i))]}"
        if [[ "${rotate:0:1}" == "(" ]]; then
            # Rotation has been omitted, meaning both rotation
            # and reflection are normal
            cmd="$cmd --rotate normal"
            cmd="$cmd --reflect normal"
            continue
        fi
        cmd="$cmd --rotate $rotate"

        reflect="${tokens[((4+i))]}" # Either "X" or "Y"
        reflect_after="${tokens[((5+i))]}" # Either "axis" or "and"
        if [ $reflect_after == "and" ]; then
            cmd="$cmd --reflect xy"
        elif [ $reflect == "X" ]; then
            cmd="$cmd --reflect x"
        else
            cmd="$cmd --reflect y"
        fi
    elif [ $state == $S_GOT_DISPLAY ]; then # Parsing a connected display's list of modes
        cmd="$cmd --mode ${tokens[0]}"

        for (( i=1; i<${#tokens[@]}; i++ )); do
            token=${tokens[i]}
            # Selected resolution/rate is marked with an asterisk * and the
            # default mode is marked with a plus +. Find the selected mode
            if [[ "$token" == *\* ]]; then
                cmd="$cmd --rate ${token:0:-1}" # Trim the *
                break
            elif [[ "$token" == *\*+ ]]; then
                cmd="$cmd --rate ${token:0:-2}" # Trim the *+
                break
            fi
        done

        # We've got all the info we need, output the xrandr command
        echo "$cmd"
        cmd="xrandr"
        state=$S_LOOKING_FOR_DISPLAY # Now look for next connected display
    fi
done < <(xrandr)

