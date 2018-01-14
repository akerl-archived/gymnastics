function getRange(rangeSpecification) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet();
  return sheet.getRange(rangeSpecification)
}

function getUnderlinedFromRange(range) {
  return range.getFontLines();
}

function getUnderlined(rangeSpecification) {
  return getUnderlinedFromRange(getRange(rangeSpecification));
}

function getUnderlinedWM(rangeSpecification, range) {
  return getUnderlined(rangeSpecification);
}

function getValuesWhereUnderlinedFromRange(range) {
  var isUnderlined = getUnderlinedFromRange(range);
  var res = [];
  for (var y = 0; y < range.getNumRows(); y++) {
    var rowRes = []
    for (var x = 0; x < range.getNumColumns(); x++) {
      if (isUnderlined[y][x] == 'underline') {
        rowRes.push(range.getCell(y+1, x+1).getValue())
      } else {
        rowRes.push(null)
      }
    }
    res.push(rowRes)
  }
  return res;
}

function getValuesWhereUnderlined(rangeSpecification) {
  return getValuesWhereUnderlinedFromRange(getRange(rangeSpecification));
}

function getValuesWhereUnderlinedWM(rangeSpecification, range) {
  return getValuesWhereUnderlined(rangeSpecification);
}

function getSumWhereUnderlinedFromRange(range) {
  return __sum(__flatten_compact(getValuesWhereUnderlinedFromRange(range)));
}

function getSumWhereUnderlined(rangeSpecification) {
  return getSumWhereUnderlinedFromRange(getRange(rangeSpecification));
}

function getSumWhereUnderlinedWM(rangeSpecification, range) {
  return getSumWhereUnderlined(rangeSpecification);
}

function getCountWhereUnderlinedFromRange(range) {
  return __flatten_compact(getValuesWhereUnderlinedFromRange(range)).length;
}
  
function getCountWhereUnderlined(rangeSpecification) {
  return getCountWhereUnderlinedFromRange(getRange(rangeSpecification));
}

function getCountWhereUnderlinedWM(rangeSpecification, range) {
  return getCountWhereUnderlined(rangeSpecification);
}

function __flatten_compact(arr, result) {
  result = typeof result !== 'undefined' ? result : [];
  var max = arr.length
  for (var i = 0; i < max; i++) {
    var val = arr[i];
    if (Array.isArray(val)) {
      __flatten_compact(val, result);
    } else if (val !== null) {
      result.push(val);
    }
  }
  return result;
}

function __sum(arr) {
  return arr.reduce(function(a, b) { return a + b }, 0);
}
