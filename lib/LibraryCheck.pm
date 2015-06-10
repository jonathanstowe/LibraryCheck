use v6;

module LibraryCheck {
   use NativeCall; 

    sub library-exists(Str $lib --> Bool) is export {
        my $rc = True;  

        my $name = ("a".."z","A".."Z").pick(15).join("");
        my $f = EVAL("sub $name\(\) is native(\{'$lib'\}) \{ * \}");
        try { 
                $f(); 
                CATCH { 
                    when /'Cannot locate native library'/  { $rc = False } 
                    default { $rc = True } 
                } 
        }
        $rc; 
    } 
}
