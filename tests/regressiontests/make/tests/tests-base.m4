ADD_SCRIPT([basic2])
ADD_TEST([stability], [[
	diff -q $< $(word 2,$^)
]], [$(TESTDIR)/basic2.sh], [$(TESTDIR)/basic.sh])

ADD_TEST([basic], [[
	$(generic_regression)
	$< -h | grep -q 'P percent: %'
	$< -h | grep -q 'O percent: %'
]])

ADD_TEST([test-void], [[
	! grep -q 'die' $<
]])

ADD_SCRIPT([test-salone])
#  the dependency $(TESTDIR)/test-standalone.sh should be assumed
ADD_TEST([call-salone], [[
	$(generic_regression)
]])

ADD_TEST([test-most], [[
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< xx yy | grep -q "POS_MORE1=xx yy,POS_MORE2=hu lu,"
	$< xx yy zz aa | grep -q "POS_MORE1=xx yy,POS_MORE2=zz aa,"
	$< -h | grep -q '<pos-more1-1> <pos-more1-2> \[<pos-more2-1>\] \[<pos-more2-2>\]'
	$< -h | grep -q '<pos-more1>: @pos-more1-arg@'
	$< -h | grep -q "<pos-more2>: @pos-more2-arg@ (defaults for <pos-more2-1> to <pos-more2-2> respectively: 'hu' and 'lu')"
]])

ADD_TEST([test-more], [[
	$< LOO x | grep -q "POS_S=LOO,POS_MORE=x f\[o\]o ba,r,"
	$< LOO lul laa | grep -q "POS_S=LOO,POS_MORE=lul laa ba,r,"
	$< LOO laa bus kus | grep -q "POS_S=LOO,POS_MORE=laa bus kus",
	ERROR="namely: 'pos-arg' and 'pos-more'" $(REVERSE) $<
	grep -q '^		_positionals' $<
]])


ADD_TEST([test-onlypos], [[
	$(_test_onlypos)
	! grep -q '^_arg_pos_arg=$$' $<
]])


ADD_TEST([test-onlypos-declared], [[
	$(_test_onlypos)
	grep -q '^_arg_pos_arg=$$' $<
]])


ADD_TEST([test-onlyopt], [[
	grep -q '^    esac$$' $<
	@# ! negates the return code
	! grep -q '^	' $<
	$(REVERSE) grep -q POSITION $<
	$< --opt-arg PoS | grep -q OPT_S=PoS,
	$< --opt-arg "PoS sob" | grep -q 'OPT_S=PoS sob,'
	$< --boo_l | grep -q 'BOOL=on'
	$< --no-boo_l | grep -q 'BOOL=off'
	$< -r /usr/lib --opt-repeated /usr/local/lib | grep -q 'ARG_REPEATED=/usr/lib /usr/local/lib,'
	$(REVERSE) $< LOO 2> /dev/null
	$< -h | grep -q -e '-B|--(no-)boo_l'
	! $< -h | grep -q -e '-B,'
	$< -h | grep -q -e '-i|--incrx'
	$< -h | grep -q -e '-i,--incrx'
	$< -h | grep -q -e '-o|--opt-arg <arg>'
	$< -h | grep -q -e '-o,--opt-arg: @opt-arg@'
	$< -h | grep -q -e '-r|--opt-repeated'
	$< -h | grep -q -e '-r,--opt-repeated:'
]])

ADD_SCRIPT([test-standalone2])
ADD_TEST([stability-salone], [[
	diff -q $< $(word 2,$^)
]],
	[$(TESTDIR)/test-standalone2.sh], [$(TESTDIR)/test-standalone.sh])

ADD_RULE([$(TESTDIR)/test-ddash.m4], [$(TESTDIR)/test-ddash-old.m4 $(ARGBASH_1TO2)],
	[$(ARGBASH_1TO2) $< -o $@
])

ADD_TEST([test-ddash], [[
	$< --boo_l | grep -q 'BOOL=on,'
	$< -- --boo_l | grep -q 'BOOL=off,'
	$< -- --boo_l | grep -q 'POS_OPT=--boo_l,'
	$< -- --help | grep -q 'POS_OPT=--help,'
	$< -- | grep -q 'POS_OPT=pos-default,'
	$< -- --| grep -q 'POS_OPT=--,'
	ERROR=spurious 	$(REVERSE) $< -- foo bar
	ERROR=bar 	$(REVERSE) $< -- foo bar
]])

ADD_TEST([test-simple], [[
	$< pos | grep -q 'OPT_S=x,POS_S=pos,'
	$< pos -o 'uf ta' | grep -q 'OPT_S=uf ta,POS_S=pos,'
	$< -h | grep -q 'END-$$'
	$< -h | grep -q '^\s*-BEGIN'
	$< -h | grep -q '^		-BEGIN'
	$< -h | grep -q -v '^\s*-BEGIN2'
	$< -h | grep -q -v 'END2-$$'
	$< -h | grep -q '^		-PBEGIN'
	$< -h | grep -q 'PEND-$$'
	grep -q '^		esac' $<
	grep -q '^			\*@:}@' $<
	ERROR=spurious 	$(REVERSE) $< -- one two
	ERROR="last one was: 'two'" 	$(REVERSE) $< one two
	ERROR="expect exactly 1" 	$(REVERSE) $< one two
	ERROR="[Nn]ot enough" 	$(REVERSE) $<
	ERROR="require exactly 1" 	$(REVERSE) $<
]])

dnl The invocation like this is supposed to trigger complaints
ADD_TEST([test-diy-noop], [[
	$< LOO --opt_arg > /dev/null
	$< LOO 1 2 3 3 > /dev/null
	$< > /dev/null
]])

ADD_RULE([$(TESTDIR)/test-diy-noop.m4], [$(TESTDIR)/basic.m4],
	[[sed -e 's/ARGBASH_GO/ARGBASH_PREPARE/' $< > $@
]])
ADD_SCRIPT([test-diy-noop], [m4])

dnl This is the body of test-simple
ADD_TEST([test-diy], [[
	$(generic_regression)
]])

ADD_RULE([$(TESTDIR)/test-diy.m4], [$(TESTDIR)/test-diy-noop.m4],
	[[sed -e 's/ARGBASH_PREPARE.*/&\nparse_commandline "$$@"\nhandle_passed_args_count\nassign_positional_args/' $< > $@
]])
ADD_SCRIPT([test-diy], [m4])


m4_define([test_wrapping_body], [[[
	$< -h | grep -q opt-arg
	$< -h | grep -q pos-arg
	@# ! negates the return code
	! $< -h | grep -q boo_l
	@# no spaces as indentation (that test-onlyopt uses)
	! grep -q '^  ' $<
	grep -q '^		esac' $<
	$< XX LOOL | grep -q 'POS_S0=XX,POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL | grep -q 'POS_S=LOOL,POS_OPT=pos-default'
	$< XX LOOL --opt-arg lalala | grep -q OPT_S=lalala,
	$< XX LOOL --opt-arg lalala | grep -q 'CMDLINE=--opt-arg lalala LOOL pos-default,'
	$< XX LOOL --opt-repeated w -r x --opt-repeated=y -rz | grep -q 'CMDLINE=--opt-repeated w -r x --opt-repeated=y -rz LOOL pos-default,'
]]])


ADD_TEST([test-wrapping], test_wrapping_body,
[$(TESTDIR)/test-onlyopt.m4 $(TESTDIR)/test-onlypos.m4])

ADD_RULE([$(TESTDIR)/test-wrapping-otherdir.sh],
	[$(TESTDIR)/test-wrapping-otherdir.m4 $(TESTDIR)/otherdir/test-onlyopt.m4 $(TESTDIR)/otherdir/test-onlypos.m4 $(ARGBASH_BIN)],
	[[$(ARGBASH_BIN) $< -o $@
]])

ADD_TEST([test-wrapping-otherdir], test_wrapping_body)

ADD_RULE([$(TESTDIR)/otherdir/test-onlyopt.m4], [$(TESTDIR)/test-onlyopt.m4],
	[[mkdir -p $(TESTDIR)/otherdir && cp $< $@
]])
ADD_SCRIPT([otherdir/test-onlyopt], [m4])

ADD_RULE([$(TESTDIR)/otherdir/test-onlypos.m4], [$(TESTDIR)/test-onlypos.m4],
	[[mkdir -p $(TESTDIR)/otherdir && cp $< $@
]])
ADD_SCRIPT([otherdir/test-onlypos], [m4])

ADD_TEST([test-wrapping-more], [[
	$< -i -i -i | grep -q 'CMDLINE=-i -i -i,'
	$< -i -i | grep -q 'OPT_INCR=4,'
	ERROR="nexpected argument '--opt-arg'" $(REVERSE) $< --opt-arg lalala
]], [$(TESTDIR)/test-onlyopt.m4])

ADD_TEST([test-wrapping-excl], [[
	$(_test_onlypos)
]], [$(TESTDIR)/test-onlypos.m4])

ADD_SCRIPT([test-wrapping2])
ADD_TEST([stability-wrapping], [[
	diff -q $< $(word 2,$^)
]],
	[$(TESTDIR)/test-wrapping2.sh], [$(TESTDIR)/test-wrapping.sh])

ADD_TEST([test-infinity-minimal_call], [[
	$< | grep -q 'POS_S='
	$< 1 | grep -q 'POS_S=1,'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
]])

ADD_TEST([test-infinity], [[
	$< | grep -q 'POS_S=first,second,third,'
	$< 1 | grep -q 'POS_S=1,second,third,'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
]])

ADD_TEST([test-infinity-nodefaults], [[
	ERROR="require at least 2" $(REVERSE) $<
	ERROR="namely: 'pos-arg' (2 times)" $(REVERSE) $<
	$< 1 "2 3" | grep -q 'POS_S=1,2 3'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
]])

ADD_TEST([test-infinity-mixed], [[
	$< -h | grep -q '<pos-arg-1> \[<pos-arg-2>\] \.\.\. \[<pos-arg-n>\] \.\.\.$$'
	ERROR="require at least 1" $(REVERSE) $<
	$< 1 | grep -q 'POS_S=1,first,second'
	$< 1 2 "3 1 4" 4 5 | grep -q 'POS_S=1,2,3 1 4,4,5,'
]])

ADD_TEST([test-leftovers], [[
	$< -h | grep -q '\[-c|--cosi <arg>\] \[--(no-)fear\] \[-m|--more\] \[-h|--help\] <another> \.\.\. $$'
	$< -c ours -m --more --more --no-fear "ours pos" left "o ver" | grep -q 'MORE=3,OPT_S=ours,FEAR=off,POS_S=ours pos,LEFTOVERS=left,o ver,'
]])

ADD_GENTEST([pos], [pos-arg])
ADD_GENTEST([opt], [opt-arg])
ADD_GENTEST([pos2], [pos_arg])
ADD_GENTEST([opt2], [opt_arg])
ADD_GENTEST([infinity-illegal], [number of expected positional arguments before 'pos-arg' is unknown (because of argument 'pos-arg', which has a default)])
ADD_GENTEST([pos-opt], [same-arg])
ADD_GENTEST([pos-opt2], [same_arg])
ADD_GENTEST([more], [is unknown])
ADD_GENTEST([illegal-pos], [contains forbidden characters])
ADD_GENTEST([illegal-opt], [one character])
ADD_GENTEST([misspelled], [ARG_FOOBAR], [ARGBASH_GOO])
dnl We have to escape \[ -> \@<:@ for grep
ADD_GENTEST([unmatched_bracket], [unmatched square bracket on line 3], [[# ARG_OPTIONAL_BOOLEAN(\[long\], l, \@<:@)]])
ADD_GENTEST([badcall-multi], [3rd argument], [num of args], [actual number of])
