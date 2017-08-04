use "collections"

class ParseRepeat[TSrc,TVal] is ParseRule[TSrc,TVal]
  """
  Matches a number of repetitions of a rule.
  """

  var _name: String
  let _child: ParseRule[TSrc,TVal] box
  let _min: USize
  let _max: USize
  let _action: (ParseAction[TSrc,TVal] val | None)

  new create(child: ParseRule[TSrc,TVal] box,
             min: USize, max: USize = USize.max_value(),
             action: (ParseAction[TSrc,TVal] val | None) = None) =>
    _name = ""
    _child = child
    _min = min
    _max = max
    _action = action

  fun can_be_recursive(): Bool => true

  fun name(): String => _name
  fun ref set_name(str: String) => _name = str

  fun description(call_stack: ParseRuleCallStack[TSrc,TVal] = None): String =>
    let desc: String trn = recover String end
    if _name != "" then desc.append("(" + _name + " = ") end
    if (_min == 0) and (_max == 1) then
      desc.append("(" + _child_description(_child, call_stack) + ")?")
    elseif _min == 0 then
      desc.append("(" + _child_description(_child, call_stack) + ")*")
    elseif _min == 1 then
      desc.append("(" + _child_description(_child, call_stack) + ")+")
    else
      desc.append("(" + _child_description(_child, call_stack) + "){"
        + _min.string() + "," + _max.string() + "}")
    end
    if _name != "" then desc.append(")") end
    desc

  fun parse(memo: ParseState[TSrc,TVal], start: ParseLoc[TSrc] box):
    (ParseResult[TSrc,TVal] | None) ? =>
    let results = Array[ParseResult[TSrc,TVal]]()
    var count: USize = 0
    var cur = start
    while count < _max do
      match memo.parse(_child, cur)?
      | let r: ParseResult[TSrc,TVal] =>
        results.push(r)
        cur = r.next
      else
        break
      end
      count = count + 1
    end
    if (count >= _min) then
      ParseResult[TSrc,TVal](memo, start, cur, results, _action)
    else
      None
    end