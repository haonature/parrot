// Copyright (C) 2006, The Perl Foundation.
// $Id$

// Transform ANTLR PAST to PIR that sets up a PAST data structure
// let the Parrot Compiler Tools handle the execution.

tree grammar AntlrPast2PirPast;

options
{
  ASTLabelType = CommonTree;
  tokenVocab   = BcParser;      // Token file is found because of '-lib' option
}

@members
{
  // used for generating unique register names
  public static int reg_num = 100;
}

gen_pir_past 
  : {
      System.out.println( 
          "#!/usr/bin/env parrot                                             \n"
        + "                                                                  \n"
        + "# Do not edit this file.                                          \n"
        + "# This file has been generated by Bc.java.                        \n"
        + "                                                                  \n"
        + "# entering 'gen_pir_past'                                         \n"
        + ".sub bc :main                                                     \n"
        + "  load_bytecode 'languages/punie/lib/ASTGrammar.pir'              \n"
        + "  load_bytecode 'languages/punie/lib/PunieOpLookup.pir'           \n"              
        + "  load_bytecode 'TGE.pbc'                                         \n"
        + "  load_bytecode 'PAST.pbc'                                        \n"
        + "  load_bytecode 'languages/punie/lib/POST.pir'                    \n"
        + "  load_bytecode 'languages/punie/lib/OSTGrammar.pir'              \n"
        + "                                                                  \n"
        + "  # initialize the 26 up named vars                               \n"
        + "  .sym pmc stmts                                                  \n"
        + "  stmts = new 'PAST::Stmts'                                       \n"
        + "                                                                  \n"
        + "  .sym pmc reg_expression_stmt                                    \n"
        + "  .sym pmc reg_expression_topexp                                  \n"
        + "  .sym pmc reg_print_op                                           \n"
        + "  .sym pmc reg_expression_exp                                     \n"
        + "  .sym pmc reg_expression_stmt                                    \n"
        + "  .sym pmc reg_expression_newline                                 \n"
        + "                                                                  \n"
        + "  .sym pmc reg_temp                                               \n"
        + "                                                                  \n"
        + "  .sym pmc reg_assign_lhs                                         \n"
        + "                                                                  \n"
        + "  .sym pmc reg_unary_val                                          \n"
        + "  .sym pmc reg_unary_op                                           \n"
        + "                                                                  \n"
        + "  .sym pmc reg_adding_expression_op                               \n"
      );
    }
    ^(PROGRAM expression["stmts"]* )
    {
      System.out.print( 
          "                                                                  \n"
        + "  # say 'AST tree dump:'                                          \n"
        + "  # stmts.dump()                                                  \n"
        + "                                                                  \n"
        + "  # Compile the abstract syntax tree                              \n"
        + "  # down to an opcode syntax tree                                 \n"
        + "  .sym string ost_tg_src                                          \n"
        + "  .sym pmc tge_compiler                                           \n"
        + "  .sym pmc ost_grammar, ost_builder, ost                          \n"
        + "  tge_compiler = new 'TGE::Compiler'                              \n"
        + "  ost_tg_src = _slurp_file('languages/punie/lib/OSTGrammar.tg')   \n"
        + "  ost_grammar = tge_compiler.'compile'(ost_tg_src)                \n"
        + "  ost_builder = ost_grammar.apply(stmts)                          \n"
        + "  ost = ost_builder.get('result')                                 \n"
        + "  unless ost goto ERR_NO_OST                                      \n"
        + "                                                                  \n"
        + "  # Compile the OST down to PIR                                   \n"
        + "  .sym string pir_tg_src                                          \n"
        + "  .sym pmc pir_grammar, pir_builder, pir                          \n"
        + "  pir_tg_src = _slurp_file('languages/punie/lib/PIRGrammar.tg')   \n"
        + "  pir_grammar = tge_compiler.'compile'(pir_tg_src)                \n"
        + "  pir_builder = pir_grammar.apply(ost)                            \n"
        + "  pir = pir_builder.get('result')                                 \n"
        + "  unless pir goto ERR_NO_PIR                                      \n"
        + "                                                                  \n"
        + "  # execute                                                       \n"
        + "  .sym pmc pir_compiler, pir_compiled                             \n"
        + "  pir_compiler = compreg 'PIR'                                    \n"
        + "  pir_compiled = pir_compiler( pir )                              \n"
        + "  pir_compiled()                                                  \n"
        + "  say ''                                                          \n"
        + "  goto CLEANUP                                                    \n"
        + "                                                                  \n"
        + "  ERR_NO_OST:                                                     \n"
        + "    say 'Unable to construct OST.'                                \n"
        + "    goto CLEANUP                                                  \n"
        + "                                                                  \n"
        + "  ERR_NO_PIR:                                                     \n"
        + "    say 'Unable to construct PIR.'                                \n"
        + "    goto CLEANUP                                                  \n"
        + "                                                                  \n"
        + "  CLEANUP:                                                        \n"
        + ".end                                                              \n"
        + "                                                                  \n"
        + ".sub _slurp_file                                                  \n"
        + "  .param string filename                                          \n"
        + "                                                                  \n"
        + "  .sym pmc filehandle                                             \n"
        + "  .sym string content                                             \n"
        + "  filehandle = open filename, '<'                                 \n"
        + "  unless filehandle goto ERR_NO_FILE                              \n"
        + "  content = read filehandle, 65535                                \n"
        + "  close filehandle                                                \n"
        + "                                                                  \n"
        + "  .return ( content )                                             \n"
        + "                                                                  \n"
        + "  ERR_NO_FILE:                                                    \n"
        + "    print 'Unable to open file: '                                 \n"
        + "    say filename                                                  \n"
        + "    end                                                           \n"
        + "                                                                  \n"
        + ".end                                                              \n"
        + "                                                                  \n"
        + "# leaving 'gen_pir_past'                                          \n"
      );
    }
  ;

expression[String reg_mother]
  : {
      System.out.print( 
          "                                                                  \n"
        + "  # entering 'expression'                                         \n"
        + "    reg_expression_stmt = new 'PAST::Stmt'                        \n"
        + "      reg_expression_topexp = new 'PAST::Exp'                     \n"
        + "        reg_print_op = new 'PAST::Op'                             \n"
        + "        reg_print_op.'op'( 'print' )                              \n"
        + "          reg_expression_exp = new 'PAST::Exp'                    \n"
      );
    }
    ^( SAY ( adding["reg_expression_exp"]
             { 
               System.out.print( 
                   "                                                                \n"
                 + "      reg_print_op.'add_child'( reg_expression_exp )            \n"
               );
             }
             |
             ^( UNARY_MINUS adding["reg_expression_exp"] )
             { 
               System.out.print( 
                   "                                                                \n"
                 + "   # multiply by -1                                             \n"
                 + "   reg_unary_op = new 'PAST::Op'                                \n"
                 + "   reg_unary_op.'op'( 'infix:*' )                               \n"
                 + "     reg_unary_val = new 'PAST::Val'                            \n"
                 + "     reg_unary_val.value( -1 )                                  \n"
                 + "     reg_unary_val.valtype( 'num' )                             \n"
                 + "   reg_unary_op.'add_child'( reg_unary_val )                    \n"
                 + "   reg_unary_op.'add_child'( reg_expression_exp )               \n"
                 + "      reg_print_op.'add_child'( reg_unary_op )                  \n"
               );
             }
           )
    )
    {
      System.out.print( 
          "                                                                  \n"
        + "      reg_expression_topexp.'add_child'( reg_print_op      )      \n"
        + "    reg_expression_stmt.'add_child'( reg_expression_topexp )      \n"
        + "  " + $expression.reg_mother + ".'add_child'( reg_expression_stmt ) \n"
        + "                                                                  \n"
        + "  # Now print a newline                                           \n"
        + "    reg_expression_stmt = new 'PAST::Stmt'                        \n"
        + "      reg_expression_topexp = new 'PAST::Exp'                     \n"
        + "        reg_print_op = new 'PAST::Op'                        \n"
        + "          reg_expression_exp = new 'PAST::Exp'                    \n"
        + "            reg_expression_newline = new 'PAST::Val'              \n"
        + "            reg_expression_newline.value( '\\n' )                 \n"
        + "            reg_expression_newline.valtype( 'strqq' )             \n"
        + "          reg_expression_exp.'add_child'( reg_expression_newline )\n"
        + "        reg_print_op.'add_child'( reg_expression_exp )       \n"
        + "        reg_print_op.'op'( 'print' )                         \n"
        + "      reg_expression_topexp.'add_child'( reg_print_op )      \n"
        + "    reg_expression_stmt.'add_child'( reg_expression_topexp )      \n"
        + "  " + $expression.reg_mother + ".'add_child'( reg_expression_stmt )\n"
        + "  # leaving 'expression'                                          \n"
      );
    }
    |
    {
      String mother_for_string = $expression.reg_mother;
    }
    (
      ^( PRINT string[ mother_for_string ] )
      |
      ^( ASSIGN_OP assign[ mother_for_string ] )
    )
  ;

string [ String reg_mother ]
  : STRING
    {
      // TODO: strip String
      System.out.print(     
          "                                                                \n"
        + "# entering 'string'                                             \n"
        + "    reg_expression_stmt = new 'PAST::Stmt'                      \n"
        + "      reg_expression_topexp = new 'PAST::Exp'                   \n"
        + "        reg_print_op = new 'PAST::Op'                      \n"
        + "        reg_print_op.'op'( 'print' )                       \n"
        + "          reg_expression_exp = new 'PAST::Exp'                  \n"
        + "            reg_temp = new 'PAST::Val'                          \n"
        + "            reg_temp.value( " + $STRING.text + " )              \n"
        + "            reg_temp.valtype( 'strqq' )                         \n"
        + "          reg_expression_exp.'add_child'( reg_temp )            \n"
        + "          null reg_temp                                         \n"
        + "        reg_print_op.'add_child'( reg_expression_exp )     \n"
        + "      reg_expression_topexp.'add_child'( reg_print_op )         \n"
        + "    reg_expression_stmt.'add_child'( reg_expression_topexp )    \n"
        + "  " + $string.reg_mother + ".'add_child'( reg_expression_stmt ) \n"
        + "# leaving 'string'                                              \n"
      );
    }
  ;

assign [ String reg_mother ]
  : {
      System.out.print( 
          "                                                                  \n"
        + "  # entering 'assign'                                             \n"
        + "    reg_assign_lhs = new 'PAST::Exp'                              \n"
      );
    }
    ^(VAR LETTER) adding["reg_assign_lhs"]
    {
      // TODO: strip String
      System.out.print(     
          "                                                                  \n"
        + "    # entering 'ASSIGN_OP ^(VAR LETTER) adding'        \n"
        + "      .sym pmc past_op                                            \n"
        + "      past_op = new 'PAST::Op'                                    \n"
        + "      past_op.'op'( 'infix:=' )                                   \n"
        + "        .sym pmc past_var                                         \n"
        + "        past_var = new 'PAST::Var'                                \n"
        + "        past_var.'varname'( '" + $LETTER.text + "' )              \n"
        + "        past_var.'vartype'( 'scalar' )                            \n"
        + "        past_var.'scope'( 'global' )                              \n"
        + "      past_op.'add_child'( past_var )                             \n"
        + "      past_op.'add_child'( reg_assign_lhs )                       \n"
        + "    " + $assign.reg_mother + ".'add_child'( past_op )             \n"
        + "    # leaving  'ASSIGN_OP named_expression NUMBER'                \n"
      );
    }
  ;


integer[ String reg_mother ]
  : NUMBER
    {
      System.out.print(     
          "                                                                \n"
        + "# entering 'integer'                                            \n"
        + "reg_temp = new 'PAST::Val'                                      \n"
        + "reg_temp.value( " + $NUMBER.text + " )                             \n"
        + "reg_temp.valtype( 'num' )                                       \n"
        + $integer.reg_mother + ".'add_child'( reg_temp )                  \n"
        + "null reg_temp                                                   \n"
        + "# leaving 'integer'                                             \n"
      );
    }
  ;

adding[String reg_mother]
  : {
      System.out.print( 
          "                                                                  \n"
        + "  # entering 'adding'                                  \n"
      );
      // Why can't I say:   integer[ $adding.reg_mother ] ???
      String mother_for_int = $adding.reg_mother;
    }
    ( integer[ mother_for_int ]
      |
      {
        reg_num++;
        String reg = "reg_" + reg_num;
        System.out.print( 
            "                                                                \n"
          + "    # entering '( PLUS | MINUS | MUL | DIV ) adding adding'       \n"
          + "      .sym pmc " + reg + "                                      \n"
          + "      " + reg + " = new 'PAST::Op'                              \n"
        );
      }
      ^( infix=( PLUS | MINUS | MUL_OP ) adding[reg] adding[reg] )
      {
        System.out.print( 
            "      " + reg + ".'op'( 'infix:" + $infix.text + "' )   \n"
          + "    reg_temp = new 'PAST::Exp'                                  \n"
          + "    reg_temp.'add_child'( " + reg + " )                         \n"
          + "      null " + reg + "                                          \n"
          + "  " + $adding.reg_mother + ".'add_child'( reg_temp ) \n"
          + "    null reg_temp                                               \n"
          + "    # leaving '( PLUS | MINUS | MUL | DIV ) adding adding'        \n"
        );
      }
      |
      named_expression[ mother_for_int ]
    )
    {
      System.out.print( 
          "  # leaving 'adding'                                   \n"
      );
    }
  ;

named_expression[String reg_mother]
  : {
      System.out.print( 
          "                                                                  \n"
        + "  # entering 'named_expression'                                  \n"
      );
    }
    ^( VAR LETTER )
    {
      System.out.print( 
          "                                                                     \n"
        + " # entering '( VAR LETTER )                                    \n"
        + "    reg_temp = new 'PAST::Var'                                 \n"
        + "    reg_temp.'varname'( '" + $LETTER.text + "' )               \n"
        + "    reg_temp.'vartype'( 'scalar' )                             \n"
        + "    reg_temp.'scope'( 'global' )                               \n"
        + "  " + $named_expression.reg_mother + ".'add_child'( reg_temp ) \n"
        + "    null reg_temp                                              \n"
        + "  # leaving '(VAR LETTER)'                                     \n"
      );
    }
  ;

