'(perl_leave :desc "block exit" 
 :targ 1 :type 178 :seq 8773 :flags 13 :private 64 :children 
(perl_enter :desc "block entry" 
 :type 177 :seq 8728) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8729 :flags 1 :private 2) 
(perl_require :desc "require" 
 :type 309 :seq 8731 :flags 6 :private 1 :children 
(perl_const :desc "constant item" 
 :type 5 :seq 8730 :flags 2 :private 64)) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8732 :flags 1 :private 2) 
(perl_sassign :desc "scalar assignment" 
 :type 36 :seq 8735 :flags 69 :private 2 :children 
(perl_const :desc "constant item" 
 :type 5 :seq 8733 :flags 2) 
(perl_null :desc "null operation" 
 :targ 15 :flags 182 :private 3 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8734 :flags 2))) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8736 :flags 1 :private 2) 
(perl_sassign :desc "scalar assignment" 
 :type 36 :seq 8739 :flags 69 :private 2 :children 
(perl_const :desc "constant item" 
 :type 5 :seq 8737 :flags 2) 
(perl_null :desc "null operation" 
 :targ 15 :flags 182 :private 19 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8738 :flags 2 :private 16))) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8740 :flags 1 :private 2) 
(perl_sassign :desc "scalar assignment" 
 :type 36 :seq 8743 :flags 69 :private 2 :children 
(perl_const :desc "constant item" 
 :type 5 :seq 8741 :flags 2) 
(perl_null :desc "null operation" 
 :targ 15 :flags 182 :private 19 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8742 :flags 2 :private 16))) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8744 :flags 1 :private 2) 
(perl_sassign :desc "scalar assignment" 
 :type 36 :seq 8747 :flags 69 :private 2 :children 
(perl_qr :desc "pattern quote (qr//)" 
 :type 32 :seq 8745 :flags 2 :private 64 :children) 
(perl_null :desc "null operation" 
 :targ 15 :flags 182 :private 19 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8746 :flags 2 :private 16))) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8748 :flags 1 :private 2) 
(perl_list :desc "list" 
 :type 141 :seq 8753 :flags 45 :private 128 :children 
(perl_pushmark :desc "pushmark" 
 :type 3 :seq 8749 :flags 33 :private 128) 
(perl_null :desc "null operation" 
 :targ 15 :flags 5 :private 19 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8750 :flags 2 :private 16)) 
(perl_null :desc "null operation" 
 :targ 15 :flags 5 :private 19 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8751 :flags 2 :private 16)) 
(perl_null :desc "null operation" 
 :targ 15 :flags 5 :private 19 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8752 :flags 2 :private 16))) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8754 :flags 1 :private 2) 
(perl_sassign :desc "scalar assignment" 
 :type 36 :seq 8760 :flags 69 :private 2 :children 
(perl_entersub :desc "subroutine entry" 
 :targ 7 :type 166 :seq 8758 :flags 70 :private 34 :children 
(perl_pushmark :desc "pushmark" 
 :type 3 :seq 8755 :flags 2) 
(perl_const :desc "constant item" 
 :type 5 :seq 8756 :flags 34 :private 64) 
(perl_method_named :desc "method with known name" 
 :type 350 :seq 8757 :flags 2)) 
(perl_null :desc "null operation" 
 :targ 15 :flags 182 :private 3 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8759 :flags 2))) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8761 :flags 1 :private 2) 
(perl_sassign :desc "scalar assignment" 
 :type 36 :seq 8766 :flags 69 :private 2 :children 
(perl_entersub :desc "subroutine entry" 
 :targ 9 :type 166 :seq 8764 :flags 70 :private 35 :children 
(perl_null :desc "null operation" 
 :targ 141 :flags 6 :children 
(perl_pushmark :desc "pushmark" 
 :type 3 :seq 8762 :flags 2) 
(perl_null :desc "null operation" 
 :targ 17 :flags 6 :private 3 :children 
(perl_gv :desc "glob value" 
 :type 7 :seq 8763 :flags 2 :private 32)))) 
(perl_padsv :desc "private variable" 
 :targ 8 :type 9 :seq 8765 :flags 178 :private 128)) 
(perl_nextstate :desc "next statement" 
 :type 174 :seq 8767 :flags 1 :private 2) 
(perl_entersub :desc "subroutine entry" 
 :targ 10 :type 166 :seq 8772 :flags 69 :private 35 :children 
(perl_null :desc "null operation" 
 :targ 141 :flags 4 :children 
(perl_pushmark :desc "pushmark" 
 :type 3 :seq 8768 :flags 2) 
(perl_null :desc "null operation" 
 :targ 15 :flags 38 :private 3 :children 
(perl_gvsv :desc "scalar variable" 
 :type 6 :seq 8769 :flags 2)) 
(perl_padsv :desc "private variable" 
 :targ 8 :type 9 :seq 8770 :flags 35) 
(perl_null :desc "null operation" 
 :targ 17 :flags 6 :private 3 :children 
(perl_gv :desc "glob value" 
 :type 7 :seq 8771 :flags 2 :private 32)))))