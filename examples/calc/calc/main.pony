
use k = "../../../kiuatan"
use "promises"
use "term"

actor Main
  new create(env: Env) =>
    env.out.print("Please enter an expression (\"quit\" to quit):")

    let prompt = "> "
    let handler = recover iso Handler(env, prompt) end
    let term = ANSITerm(Readline(consume handler, env.out), env.input)
    term.prompt(prompt)

    let input_notify = object iso
      fun ref apply(data: Array[U8] iso) =>
        term(consume data)

      fun ref dispose() =>
        term.dispose()
    end
    env.input(consume input_notify)


class Handler is ReadlineNotify
  let _env: Env
  let _prompt: String
  let _grammar: k.Rule[U8, F64]

  new create(env: Env, prompt: String) =>
    _env = env
    _prompt = prompt
    _grammar = recover GrammarBuilder.expression() end

  fun ref apply(line: String, prompt: Promise[String]) =>
    if (line == "quit") or (line.size() == 0) then
      prompt.reject()
    else
      let parser = k.Parser[U8, F64]([line])
      parser.parse(_grammar, {(result) =>
        match result
        | let success: k.Success[U8, F64] =>
          _env.out.print(" => " + success.value().string())
        | let failure: k.Failure[U8, F64] =>
          _env.out.print("Unable to parse expression!")
        end
        prompt(_prompt)
      })
    end
