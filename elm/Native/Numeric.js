var numeric = numeric || null;
if(numeric === null) throw('numeric.js not found')

Elm.Native.Numeric = {};
Elm.Native.Numeric.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Numeric = elm.Native.Numeric || {};
  if (elm.Native.Numeric.values) return elm.Native.Numeric.values;

  var A = Elm.Native.Array.make(elm);
  var L = Elm.Native.List.make(elm);
  var Maybe = Elm.Maybe.make(elm);
  var Utils = Elm.Native.Utils.make(elm);
  var JS = Elm.Native.JavaScript.make(elm);

  function map(ary, f) {
    var len = ary.length, out = new Array(len);
    for(var i = 0, len = ary.length; i < len; i++)
      out[i] = f(ary[i], i);

    return out;
  }

  function matrixToJSArray(m) {
    return map(A.toJSArray(m), A.toJSArray);
  }

  function jsArrayToMatrix(m) {
    return A.fromJSArray(map(m, A.fromJSArray));
  }

  function mmDot(m1, m2) {
    m1 = matrixToJSArray(m1);
    m2 = matrixToJSArray(m2);

    var result = numeric.dot(m1, m2);
    return jsArrayToMatrix(result);
  }

  function transpose(m) {
    m = matrixToJSArray(m);
    var t = numeric.transpose(m);
    return jsArrayToMatrix(t);
  }

  function inverse(m) {
    m = matrixToJSArray(m);
    var result = numeric.inv(m);

    if(result && result[0] && result[0][0] &&
       result[0][0] !== Infinity && result[0][0] !== -Infinity)
      return Maybe.Just(jsArrayToMatrix(result))
    else
      return Maybe.Nothing
  }

  function mmPlus(m1,m2) {
    m1 = matrixToJSArray(m1);
    m2 = matrixToJSArray(m2);

    return jsArrayToMatrix(numeric.add(m1,m2))
  }

  function makeImVect(len, im) {
    if(im === undefined) {
      im = new Array(len);
      for(var i = 0; i < len; i++) im[i] = 0;
    }

    return A.fromJSArray(im);
  }

  function makeImMatrix(len, im) {
    if(im === undefined) {
      im = new Array(len);
      for(var i = 0; i < len; i++) im[i] = 0;
    }

    return A.fromArray(im);
  }

  function eig(m) {
    m = matrixToJSArray(m);
    var result = numeric.eig(m);

    var lambda = result.lambda;
    var eigenvalues = JS.toRecord({real: [], imaginary: []});
    eigenvalues.real = L.fromArray(lambda.x);
    eigenvalues.imaginary = makeImVect(lambda.x.length, lambda.y);

    var E = result.E;
    var eigenvectors = JS.toRecord({real: [], imaginary: []});
    // it turns out that numeric.js returns the eigenvectors as columns, so we transpose
    eigenvectors.real = L.fromArray(map(numeric.transpose(E.x), A.fromJSArray));
    if(E.y) {

    }
    //TODO: Fix this
    eigenvectors.imaginary = L.fromArray([]);

    var out = JS.toRecord({
      eigenvalues: [],
      eigenvectors: []
    });

    out.eigenvectors = eigenvectors;
    out.eigenvalues = eigenvalues;

    return out;
  }

  return Elm.Native.Numeric.values = {
    eig: eig,
    transpose: transpose,
    inverse: inverse,
    mmDot: F2(mmDot),
    mmPlus: F2(mmPlus)
  };
};
