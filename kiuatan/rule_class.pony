
use "collections"

class RuleClass[
  TSrc: (Hashable #read & Equatable[TSrc] #read & Stringable #read),
  TVal = None] is ParseRule[TSrc,TVal]
  """
  Matches any of a set of inputs.
  """

  let _expected: Set[TSrc] box
  let _action: (ParseAction[TSrc,TVal] val | None)

  new create(expected: Set[TSrc] box,
             action: (ParseAction[TSrc,TVal] val | None) = None) =>
    _expected = expected
    _action = action

  new from_iter(
    expected: Iterator[TSrc],
    action: (ParseAction[TSrc,TVal] val | None) = None)
  =>
    let expected' = Set[TSrc]
    for item in expected do
      expected'.set(item)
    end
    _expected = expected'
    _action = action

  fun _description(call_stack: List[ParseRule[TSrc,TVal] box]): String =>
    recover
      let s = String
      s.append("[")
      for item in _expected.values() do
        s.append(item.string())
      end
      s.append("]")
      s
    end

  fun parse(state: ParseState[TSrc,TVal], start: ParseLoc[TSrc] box)
    : (ParseResult[TSrc,TVal] | ParseErrorMessage | None) ?
  =>
    let cur = start.clone()
    if cur.has_next() then
      let actual = cur.next()?
      if _expected.contains(actual) then
        ParseResult[TSrc,TVal](state, start, cur, this,
          Array[ParseResult[TSrc,TVal]], _action)
      end
    end
