#!/usr/local/bin/perl
# $RCSfile: Debug.pm,v $
package Debug;

sub logvalue{
  my($name, $value) = @_;
  $Debug .= "$name = ";
  $Debug .= GenStruct::GenPrint($value, 1);
  $Debug .= "\n";
  print STDERR "$name = ";
  print STDERR GenStruct::GenPrint($value, 1);
  print STDERR "\n";
}

sub MakePrinter{
  my($foo) = @_;
  my $clos = sub {
    print $foo @_;
  };
  return $clos;
}

sub MakeQueuer{
  my($foo) = @_;
  if(ref($foo) =~ /Http/){
    my $clos = sub {
      for my $i (@_){
        my $text = $i;
        $text =~ s/&/&amp;/g;
        $text =~ s/</&lt;/g;
        $text =~ s/>/&gt;/g;
        $foo->queue($text);
      }
    };
    return $clos;
  } else {
    my $clos = sub {
      for my $i (@_){
        $foo->queue($i);
      }
    };
    return $clos;
  }
}

sub IsBlessed {
  my($var) = @_;
  my $builtin = {
    CODE => 1,
    ARRAY => 1,
    SCALAR => 1,
    REF => 1,
    HASH => 1,
    GLOB => 1
  };
  if(ref($var) eq "" || exists($builtin->{ref($var)})){
    return 0;
  }
  return 1;
}


sub GenCopy{
        my($var) = @_;
        my $ret;
        my $Type = ref($var);
        if ($Type eq "SCALAR"){
                $ret = \$$var;
        } elsif ($Type eq ""){
                $ret = $var;
        } elsif ($Type eq "HASH"){
                $ret = {};
                for $i (keys(%$var)){
                        $ret->{$i} = GenCopy($var->{$i});
                }
        } elsif ($Type eq "ARRAY"){
                $ret = [];
                my $i;
                for ($i = 0; $i <= $#{$var}; $i++ ){
                        $ret->[$i] = GenCopy($var->[$i]);
                }
        } else {
                $ret = "UNKNOWN TYPE";
        }
        return $ret;
}

sub GenPrint{
        my($printer, $var, $depth, $to) = @_;
        my $ret;
        if(ref($printer) ne "CODE"){
          if(ref($printer) eq "ARRAY"){
            my $printerarg = $printer;
            $printer = sub {
              my($text) = @_;
              push(@{$printerarg}, $text);
            }
          } elsif(ref($printer) eq "SCALAR"){
            my $printerarg = $printer;
            $printer = sub {
              my($text) = @_;
              $$printer .= $text;
            }
          } elsif(ref($printer) eq ""){
            $printer = sub {
              my($text) = @_;
              $ret .= $text;
            }
          } elsif($printer->isa("FileHandle")){
            my $printerarg = $printer;
            $printer = sub {
              my($text) = @_;
              $printerarg->print($text);
            }
          } else {
            print STDERR "Error bad printer parameter\n";
            return;
          }
        }
        my $Type = ref($var);
        if(defined($to) && $depth >= $to && $Type){
          &$printer("-$Type-");
          return;
        }
        if ($Type eq "SCALAR"){
                &$printer("->$$var");
        } elsif (
          $Type eq "HASH" || 
          (IsBlessed($var) && $var->isa("HASH"))
        ){
                &$printer("{\n");
                my @tempkeys = sort(keys(%$var));
                my $i;
                for ($i = 0; $i < $#tempkeys; $i++){
                        &$printer("  " x $depth);
                        &$printer("\"$tempkeys[$i]\" => ");
                        GenPrint($printer,
                          $var->{$tempkeys[$i]}, $depth + 1, $to);
                        &$printer(",\n");
                }
                if($#tempkeys >= 0){
                        &$printer("  " x $depth);
                        &$printer("\"$tempkeys[$#tempkeys]\" => ");
                        GenPrint($printer,
                           $var->{$tempkeys[$#tempkeys]},
                                $depth + 1, $to);
                        &$printer("\n");
                }
                if($depth > 0){
                        &$printer("  " x ($depth - 1));
                        &$printer("}");
                }
        } elsif (
          $Type eq "ARRAY" || 
          (IsBlessed($var) && $var->isa("ARRAY"))
        ){
                &$printer("[\n");
                my $i;
                for ($i = 0; $i < $#{$var}; $i++ ){
                        &$printer("  " x $depth);
                        GenPrint($printer, $var->[$i], $depth + 1, $to);
                        &$printer(",\n");
                }
                if($#{$var} >= 0){
                        &$printer("  " x $depth);
                        GenPrint($printer, 
                          $var->[$#{$var}], $depth +1, $to);
                        &$printer("\n");
                }
                if($depth > 0){
                        &$printer("  " x ($depth - 1));
                        &$printer("]");
                }
        } elsif ($Type eq ""){
                unless($var){ $var = "" }
                $var =~ s/\@/\\\@/g;
                &$printer("\"$var\"");
        } else {
                $var =~ s/\@/\\\@/g;
                &$printer("\"$var\"");
                return;
        }
        return $ret;
}

sub DifferentArrays{
        my($Spec, $Diff) = @_;
        my $i;
        if($#{$Spec} != $#{$Diff}){
                return 1;
        }
        for($i = 0; $i <= $#{$Spec}; $i++){
                if($Spec->[$i] ne $Diff->[$i]){
                        return 1;
                }
        }
        return 0;
}
sub GenCompare{
        my($Spec, $SpecTitle, $Desc, $DescTitle) = @_;
        my $SpecType = ref($Spec);
        my $DescType = ref($Desc);
        my $i;
        if($SpecType ne $DescType){
                return +{$SpecTitle => $Spec,
                        $DescTitle => $Desc };
        }
        if($SpecType eq ""){
                if($Spec eq $Desc){
                        return "";
                } else {
                        return+{$SpecTitle => $Spec,
                                $DescTitle => $Desc };
                }
        } elsif ($SpecType eq "HASH") {
                my $OIS = [];
                my $OID = [];
                my $Compare = [];
                my $Diffs = [];
                for $i(keys(%$Spec)){
                        if(! defined $Desc->{$i}){
                                push(@$OIS, {$i => $Spec->{$i}});
                        } else {
                                push(@$Compare, $i);
                        }
                }
                for $i(keys(%$Desc)){
                        if(! defined $Spec->{$i}){
                                push(@$OID, {$i => $Desc->{$i}});
                        }
                }
                for $i (@$Compare){
                        my $Res = GenCompare($Spec->{$i}, 
                                "$SpecTitle\-\>{$i}",
                                $Desc->{$i},
                                "$DescTitle\-\>{$i}");
                        if($Res ne ""){
                                push(@$Diffs, $Res);
                        }
                }
                if($#{$OIS} < 0 && $#{$OID} < 0 && $#{$Diffs} < 0){
                        return "";
                }
                my $ret = {};
                if($#{$OIS} >= 0){
                        $ret->{$SpecTitle} = $OIS;
                }
                if($#{$OID} >= 0){
                        $ret->{$DescTitle} = $OID;
                }
                if($#{$Diffs} >= 0){
                        $ret->{Differences} = $Diffs;
                }
                return $ret;
        } elsif ($SpecType eq "ARRAY") {
                if(DifferentArrays($Spec, $Desc)){
                        return +{$SpecTitle => $Spec,
                                $DescTitle => $Desc};
                } else {
                        return "";
                }
        } elsif ($SpecType eq "SCALAR") {
                if($$Spec eq $$Desc){
                        return "";
                } else {
                        return +{$SpecTitle => $Spec,
                                $DescTitle => $Desc};
                }
        } else {
                return +{$SpecTitle => $Spec,
                        $DescTitle => $Desc};
        }
}
sub HtmlDump{
  my($http, $base_name, $struct, $depth, $current_path, $base_url, $link ) = @_;
  my $q = MakeQueuer($http->{output_queue});
  my $indent = 0;
  my $url = "$base_url?$base_name+$link";
  &$q("<a href=\"$url\">\$$base_name</a>");
  my $where = $struct;
  for my $i (0 ..$#{$current_path}){
    my $cp = $current_path->[$i];
    $url .= "+$cp";
    if(
      ref($where) eq "ARRAY" ||
      (IsBlessed($where) && $where->isa("ARRAY"))
    ){
      &$q("->[<a href=\"$url\">$cp<a>]");
      $where = $where->[$cp];
    } elsif(
      ref($where) eq "HASH" ||
      (IsBlessed($where) && $where->isa("HASH"))
    ){
      &$q("->{<a href=\"$url\">$cp<a>}");
      $where = $where->{$cp};
    } else {
      &$q("ERROR - not an ARRAY or HASH\n</pre>");
      return;
    }
  }
  &$q(" = ");
  HtmlDumpStruct($q, $where, $url, 0, $depth);
}
sub QueueNonHtmlText{
  my($q, $text) = @_;
  $text =~ s/\n/\\n/g;
  $text =~ s/\@/\\@/g;
  $text =~ s/&/&amp;/g;
  $text =~ s/</&lt;/g;
  $text =~ s/>/&gt;/g;
  &$q($text);
}
sub QueueHtmlText{
  my($q, $text) = @_;
  $text =~ s/\@/\\@/g;
  &$q($text);
}
sub HtmlDumpStruct{
  my($q, $struct, $url, $indent, $depth) = @_;
  if($depth <= 0){
    my $ref = ref($struct);
    if($ref eq ""){
      QueueNonHtmlText($q, "\"$struct\"");
    } else {
      &$q("-<a href=\"$url\">$ref</a>-");
    }
    return;
  }
  if(
    ref($struct) eq "ARRAY" ||
    (IsBlessed($struct) && $struct->isa("ARRAY"))
  ){
    &$q("[\n");
    for my $i (0 .. $#{$struct}){
      my $new_url = "$url+$i";
      my $new_indent = $indent + 1;
      QueueHtmlText($q, "  " x $new_indent . "<a href=\"$new_url\">");
      QueueNonHtmlText($q,"$i:");
      QueueHtmlText($q,"</a> ");
      HtmlDumpStruct($q, $struct->[$i], $new_url, $new_indent, $depth - 1);
      if($indent == 0){
        QueueHtmlText($q, "\n");
      } else {
        QueueHtmlText($q, ",\n");
      }
    }
    QueueHtmlText($q, "  " x $indent . "]");
  } elsif(
    ref($struct) eq "HASH" ||
    (IsBlessed($struct) && $struct->isa("HASH"))
  ){
    &$q("{\n");
    for my $i (sort keys %$struct){
      my $new_url = "$url+$i";
      my $new_indent = $indent + 1;
      QueueHtmlText($q, "  " x $new_indent . "<a href=\"$new_url\">");
      QueueNonHtmlText($q,"$i");
      QueueHtmlText($q,"</a> => ");
      HtmlDumpStruct($q, $struct->{$i}, $new_url, $new_indent, $depth - 1);
      if($indent == 0){
        QueueHtmlText($q, "\n");
      } else {
        QueueHtmlText($q, ",\n");
      }
    }
    QueueHtmlText($q, "  " x $indent . "}");
  } elsif (ref($struct) eq "") {
    QueueNonHtmlText($q, "\"$struct\"");
  } else {
    my $ref = ref($struct);
    QueueNonHtmlText($q, $ref);
  }
}
1;
