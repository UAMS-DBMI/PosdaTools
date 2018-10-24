#!/usr/bin/perl
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use XML::Parser;
use DBI;
unless($#ARGV == 0) {
  die "usage: PopulateDicomXml.pl <file>";
}
my $db = DBI->connect("dbi:Pg:dbname=dicomxml", undef, undef);
my $create_document = $db->prepare(
  "insert into xml_document (xml_file) values (?)"
);
my $get_doc_id = $db->prepare(
  "select currval('xml_document_xml_document_id_seq') as id"
);
my $create_element = $db->prepare(
  "insert into xml_element (xml_element_name, xml_document_id, xml_element_depth) values (?, ?, ?)"
);
my $get_element_id = $db->prepare(
  "select currval('xml_element_xml_element_id_seq') as id"
);
my $create_text = $db->prepare(
  "insert into xml_text_field (xml_text_field_text, xml_document_id, xml_text_field_depth)\n" .
  "values (?, ?, ?)"
);
my $get_text_id = $db->prepare(
  "select currval('xml_text_field_xml_text_field_id_seq') as id"
);
my $insert_element_in_doc = $db->prepare(
  "insert into xml_document_content\n" .
  "  (xml_document_content_is_element, xml_element_id, xml_document_id,\n" .
  "  xml_document_sequence)\n" .
  "values\n" .
  "  (true, ?, ?, ?)"
);
my $insert_element_in_element = $db->prepare(
  "insert into xml_element_content\n" .
  "  (xml_element_content_is_element, xml_element_id,\n" .
  "  xml_containing_element_id, xml_element_sequence)\n" .
  "values\n" .
  "  (true, ?, ?, ?)"
);
my $insert_text_in_document = $db->prepare(
  "insert into xml_document_content\n" .
  "  (xml_document_content_is_element, xml_text_field_id,\n" .
  "  xml_document_id, xml_document_sequence)\n" .
  "values\n" .
  "  (false, ?, ?, ?)"
);
my $insert_text_in_ele = $db->prepare(
  "insert into xml_element_content\n" .
  "  (xml_element_content_is_element, xml_text_field_id,\n" .
  "  xml_containing_element_id, xml_element_sequence)\n" .
  "values\n" .
  "  (false, ?, ?, ?)"
);
my $insert_attribute = $db->prepare(
  "insert into xml_element_attribute\n" .
  "  (xml_element_id, xml_attribute_key, xml_attribute_value)" .
  " values\n" .
  "   (?, ?, ?)"
);
my $insert_xml_ele_ancestor = $db->prepare(
  "insert into xml_ele_ancestor_elements(" .
  "  xml_element_id,\n" .
  "  xml_ele_ancestor_element_id,\n" .
  "  xml_ele_ancestor_element_depth\n" .
  ") values (\n" .
  "  ?, ?, ?\n" .
  ")"
);
my $insert_xml_txt_ancestor = $db->prepare(
  "insert into xml_txt_ancestor_elements(" .
  "  xml_text_field_id,\n" .
  "  xml_txt_ancestor_element_id,\n" .
  "  xml_txt_ancestor_element_depth\n" .
  ") values (\n" .
  "  ?, ?, ?\n" .
  ")"
);
{
  package XmlSchemaInsert;
  sub new{
    my($class,$document) = @_;
    my $this = {
      depth => 0
    };
    $create_document->execute($document);
    $get_doc_id->execute;
    my $h = $get_doc_id->fetchrow_hashref;
    $get_doc_id->finish;
    $this->{document} = [$document, $h->{id}, 0];
    return bless $this, $class;
  }
  sub Handlers{
    my($this) = @_;
    my $start = $this->Start;
    my $end = $this->End;
    my $char = $this->Char;
    return ($start, $end, $char);
  }
  sub Start{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $el = shift;
      my %attrs = @_;
      #---
      #  If collapsing strings, put last string
      #  <here>
      #  and at element end
      if(
        exists($this->{cur_string}) && 
        defined($this->{cur_string}) &&
        $this->{cur_string} ne ""
      ){
        $this->PutString($this->{cur_string});
        delete $this->{cur_string};
      }
#      print STDERR "Start <$el --\n";
      $create_element->execute($el, $this->{document}->[1], $this->{depth});
      $get_element_id->execute;
      my $h = $get_element_id->fetchrow_hashref;
      $get_element_id->finish;
      my $ele_id = $h->{id};
      if(exists $this->{cur_ele}){
        unless(defined $this->{cur_ele}){
          print STDERR "cur_ele exists but is undefined\n";
        }
        unless(ref($this->{cur_ele}) eq "ARRAY"){
          die "cur_ele is not an ARRAY ($this->{cur_ele})";
        }
        $insert_element_in_element->execute(
          $ele_id, $this->{cur_ele}->[1],
          $this->{cur_ele}->[2]
        );
        $this->{cur_ele}->[2] += 1;
      } else {
        $insert_element_in_doc->execute(
          $ele_id, $this->{document}->[1], 
          $this->{document}->[2]
        );
        $this->{document}->[2] += 1;
      }
      unless(exists $this->{ele_stack}){ $this->{ele_stack} = [] }
      if(exists $this->{cur_ele}) {
        push @{$this->{ele_stack}}, $this->{cur_ele};
      }
      $this->{depth} += 1;
      $this->{cur_ele} = [$el, $ele_id, 0, $this->{depth}];
      for my $i (keys %attrs){
        $insert_attribute->execute($ele_id, $i, $attrs{$i});
      }
#      #!!!!! ToDo: Populate xml_ele_ancestor_elements
#my $insert_xml_ele_ancestor = $db->prepare(
#  "insert into xml_ele_ancestor(" .
#  "  xml_element_id,\n" .
#  "  xml_ele_ancestor_element_depth,\n" .
#  "  xml_ele_ancestor_element_id\n" .
#  ") values (\n" .
#  "  ?, ?, ?\n" .
#  ")"
#);
#      print STDERR "Populate xml_ele_ancestor ($this->{depth})\n";
#      $this->print_cur_ele;
#      $this->dump_ele_stack;
#      print STDERR "-------\n";
      for my $i (@{$this->{ele_stack}}){
        $insert_xml_ele_ancestor->execute(
          $this->{cur_ele}->[1],
          $i->[1],
          $i->[3]
        );
      }
    };
    return $sub;
  };
  sub Char{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $string = shift;
      #---
      # if collapsing strings, collapse
      # <here>
      # and you're done
      # otherwise put string
      #$this->PutString($string);
      if($string =~ /^\s+$/) { $string = " " };
      if(exists $this->{cur_string}) {
        $this->{cur_string} .= $string;
      } else {
        $this->{cur_string} = $string;
      }
    };
    return $sub;
  };
  sub End{
    my($this) = @_;
    my $sub = sub {
      my $parser = shift;
      my $el = shift;
      #---
      #  If collapsing strings, put last string
      #  <here>
      #  and at element end
      if(
        exists($this->{cur_string}) && 
        defined($this->{cur_string}) &&
        $this->{cur_string} ne ""
      ){
        $this->PutString($this->{cur_string});
        delete $this->{cur_string};
      }
      if(exists $this->{ele_stack} && $#{$this->{ele_stack}} >= 0){
        $this->{depth} -= 1;
        $this->{cur_ele} = pop(@{$this->{ele_stack}});
        unless(ref($this->{cur_ele}) eq "ARRAY"){
          die "popped a non array";
        }
      } else {
        $this->{depth} -= 1;
        delete $this->{cur_ele};
      }
      if($#{$this->{ele_stack}} < 0) { delete $this->{ele_stack} }
    };
  };
  sub PutString{
    my($this, $string) = @_;
    $create_text->execute($string, $this->{document}->[1], $this->{depth} + 1);
    $get_text_id->execute;
    my $h = $get_text_id->fetchrow_hashref;
    $get_text_id->finish;
    my $text_id = $h->{id};
    if(exists $this->{cur_ele}){
      $insert_text_in_ele->execute(
        $text_id,
        $this->{cur_ele}->[1],
        $this->{cur_ele}->[2]
      );
      $this->{cur_ele}->[2]  += 1;
    } else {
      $insert_text_in_document->execute(
        $text_id,
        $this->{document}->[1],
        $this->{document}->[2]
      );
      $this->{document}->[2] += 1;
    }
#    #!!!!!!!! ToDo:  Populate xml_txt_ancestor_elements
#    my $text_depth = $this->{depth} + 1;
#    print STDERR "Populate xml_txt_ancestor ($text_depth)\n";
#    print STDERR "text: \"$string\"\n";
#    $this->print_cur_ele;
#    $this->dump_ele_stack;
#    print STDERR "-------\n";
#my $insert_xml_txt_ancestor = $db->prepare(
#  "insert into xml_txt_ancestor(" .
#  "  xml_text_field_id,\n" .
#  "  xml_txt_ancestor_element_depth,\n" .
#  "  xml_txt_ancestor_element_id\n" .
#  ") values (\n" .
#  "  ?, ?, ?\n" .
#  ")"
#);
    $insert_xml_txt_ancestor->execute(
      $text_id,
      $this->{cur_ele}->[1],
      $this->{cur_ele}->[3]
    );
    for my $i (@{$this->{ele_stack}}){
      $insert_xml_txt_ancestor->execute(
        $text_id,
        $i->[1],
        $i->[3]
      );
    }

    # If you want to index the text,
    # <here>
    # is the place to do it
    if($string =~ /^\s*$/) { return }
    #---
    my @words = split(/[\s,\.\?\"\'\(\)\[\}\]\{\;\:\=\+\/\*]+/, $string);
    for my $word (@words){
      my $str_id = $this->GetWordId($word);
      $this->InsertWordOccurance($str_id, $text_id);
    }
  }
  sub GetWordId{
    my($this, $word) = @_;
    my $get_word_id = $db->prepare(
      "select xml_word_in_text_id from xml_word_in_text where " .
      "xml_word_in_text = ?"
    );
    $get_word_id->execute($word);
    my $h = $get_word_id->fetchrow_hashref;
    if($h && ref($h) eq "HASH"){ return $h->{xml_word_in_text_id} }
    $get_word_id->finish;
    my $create_word_in_text = $db->prepare(
      "insert into xml_word_in_text(xml_word_in_text) values (?)"
    );
    $create_word_in_text->execute($word);
    my $get_new_word_id = $db->prepare(
      "select currval('xml_word_in_text_xml_word_in_text_id_seq') as id"
    );
    $get_new_word_id->execute;
    $h = $get_new_word_id->fetchrow_hashref;
    if($h) { return $h->{id} }
    die "unable to create a new xml_word_in_text row";
  }
  sub InsertWordOccurance{
    my($this, $word_id, $text_id) = @_;
    my $insert_word_occurance = $db->prepare(
      "insert into xml_word_occurance_in_text(\n" .
      "  xml_word_in_text_id, xml_text_field_id, xml_preceding_word_id\n" .
      ") values (\n".
      "  ?,?,?\n" .
      ")"
    );
    $insert_word_occurance->execute($word_id, $text_id, $this->{last_word_id});
    $this->{last_word_id} = $word_id;
  }
  sub print_cur_ele{
    my($this) = @_;
    print STDERR "cur_ele: [";
    for my $i (0 .. $#{$this->{cur_ele}}){
      print STDERR "$this->{cur_ele}->[$i]";
      unless($i eq $#{$this->{cur_ele}}) { print STDERR ", " }
    }
    print STDERR "]\n";
  }
  sub dump_ele_stack{
    my($this) = @_;
    unless(exists $this->{ele_stack}) {
      print STDERR "Ele stack: doesn't exist\n";
      return;
    }
    unless(ref($this->{ele_stack}) eq "ARRAY") {
      print STDERR "Ele stack: non_array\n";
      return;
    }
    unless($#{$this->{ele_stack}} >= 0) {
      print STDERR "Ele stack: empty\n";
      return;
    }
    print STDERR "Ele stack:\n";
    for my $i (@{$this->{ele_stack}}){
      unless(ref($i) eq "ARRAY"){
        die "non ARRAY on ele_stack";
      }
      print STDERR "\t[";
      for my $j (0 .. $#{$i}){
        print STDERR ($i->[$j]);
        unless($j == $#{$i}){ print STDERR ", " }
      }
      print STDERR "]\n";
    }
  }
}
my $obj = XmlSchemaInsert->new($ARGV[0]);;
my($start, $end, $char) = $obj->Handlers;
my $parser = XML::Parser->new(Handlers => {
  Start => $start,
  End => $end,
  Char => $char
});
$parser->parsefile($ARGV[0]);
