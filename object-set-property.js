/**
 * This is copied from
 * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty/Additional_examples
 * You may also need refer to
 * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty
 *
 * This snippet adds a new method to Object.
 * And this makes it easier to define property to object.
 *
 * @author yang_l@worksap.co.jp (YANG Ling)
 */

// creating a new Object method named Object.setProperty()
new (function() {
  var oDesc = this;
  /*
   *  :: function setProperty ::
   *
   *  nMask is a bitmask:
   *   flag 0x1: property is enumerable,
   *   flag 0x2: property is configurable,
   *   flag 0x4: property is writable,
   *   flag 0x8: property is accessor descriptor.
   *  oObj is the object on which to define the property;
   *  sKey is the name of the property to be defined or modified;
   *  vVal_fGet is the value to assign to a data descriptor or the getter function to assign to
   *  an accessor descriptor (depending on the bitmask);
   *  fSet is the setter function to assign to an accessor descriptor;
   *
   *  Bitmask possible values:
   *
   *   0  : readonly data descriptor - not configurable, not enumerable (0000).
   *   1  : readonly data descriptor - not configurable, enumerable (0001).
   *   2  : readonly data descriptor - configurable, not enumerable (0010).
   *   3  : readonly data descriptor - configurable, enumerable (0011).
   *   4  : writable data descriptor - not configurable, not enumerable (0100).
   *   5  : writable data descriptor - not configurable, enumerable (0101).
   *   6  : writable data descriptor - configurable, not enumerable (0110).
   *   7  : writable data descriptor - configurable, enumerable (0111).
   *   8  : accessor descriptor - not configurable, not enumerable (1000).
   *   9  : accessor descriptor - not configurable, enumerable (1001).
   *   10 : accessor descriptor - configurable, not enumerable (1010).
   *   11 : accessor descriptor - configurable, enumerable (1011).
   *
   *   Note: If the flag 0x8 is setted to "accessor descriptor" the flag 0x4 (writable)
   *   will be ignored. If not, the fSet argument will be ignored.
   */

  Object.setProperty = function (nMask, oObj, sKey, vVal_fGet, fSet) {
    if (nMask & 8) {
      // accessor descriptor
      if (vVal_fGet) {
        oDesc.get = vVal_fGet;
      } else {
        delete oDesc.get;
      }
      if (fSet) {
        oDesc.set = fSet;
      } else {
        delete oDesc.set;
      }
      delete oDesc.value;
      delete oDesc.writable;
    } else {
      // data descriptor
      if (arguments.length > 3) {
        oDesc.value = vVal_fGet;
      } else {
        delete oDesc.value;
      }
      oDesc.writable = Boolean(nMask & 4);
      delete oDesc.get;
      delete oDesc.set;
    }
    oDesc.enumerable = Boolean(nMask & 1);
    oDesc.configurable = Boolean(nMask & 2);
    Object.defineProperty(oObj, sKey, oDesc);
    return oObj;
  };
})();

/** Usage */

/**
 creating a new empty object
 var myObj = {};

 // adding a writable data descriptor - not configurable, not enumerable
 Object.setProperty(4, myObj, "myNumber", 25);

 // adding a readonly data descriptor - not configurable, enumerable
 Object.setProperty(1, myObj, "myString", "Hello world!");

 // etc. etc.
*/
