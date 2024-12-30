#!/bin/bash
translate()
{
    awk '{
        switch (substr($3, 0, 11)) {
        case "10.66.0.168" : printf "Audrey %s\n",$8; break;
        case "10.66.0.66." : printf "Emma   %s\n",$8; break;
        case "10.66.0.152" : printf "Emma2  %s\n",$8; break;
        case "10.66.0.39." : printf "Eric   %s\n",$8; break;
        case "10.66.0.16." : printf "Eric2  %s\n",$8; break;
        default : printf "$3 $8"; break;
        }
    }'
}
