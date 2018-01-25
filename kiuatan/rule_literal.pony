
class RuleLiteral[
  TSrc: (Equatable[TSrc] #read & Stringable #read),
  TVal = None] is RuleNode[TSrc,TVal]
  """
  Matches a literal sequence of inputs.
  """

  let _expected: ReadSeq[TSrc] box
  let _action: (ParseAction[TSrc,TVal] val | None)

  new create(
    expected: ReadSeq[TSrc] box,
    action: (ParseAction[TSrc,TVal] val | None) = None)
  =>
    _expected = expected
    _action = action

  fun is_terminal(): Bool => true

  fun _description(stack: Seq[RuleNode[TSrc,TVal] tag]): String =>
    recover
      let s = String
      s.append("\"")
      for item in _expected.values() do
        s.append(item.string())
      end
      s.append("\"")
      s
    end

  fun parse(state: ParseState[TSrc,TVal], start: ParseLoc[TSrc] val,
    cs: CallState[TSrc,TVal])
    : (ParseResult[TSrc,TVal] val | ParseErrorMessage val | None) ?
  =>
    let cur = start.clone()
    for expected in _expected.values() do
      if not cur.has_next() then return None end
      let actual = cur.next()?
      if expected != actual then return None end
    end

    let cur': ParseLoc[TSrc] val = cur.clone()
    recover
      ParseResult[TSrc,TVal](start, cur', this,
        recover Array[ParseResult[TSrc,TVal] val] end, _action)
    end
