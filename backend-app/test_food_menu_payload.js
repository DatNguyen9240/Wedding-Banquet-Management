import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const source = fs.readFileSync(new URL('../src/js/utils/FoodSelectionPlugin.js', import.meta.url), 'utf8');
const start = source.indexOf('  function _writeInputs(modal)');
const end = source.indexOf('  function _getComparisonList', start);
const context = vm.createContext({
    selectedFoodsMan: [{MaMon:'M1',TenMon:'Soup',IsChay:0,DonGia:100}],
    selectedFoodsChay: [{MaMon:'C1',TenMon:'Mushrooms',IsChay:1,DonGia:80}],
    selectedThucUong: [], selectedDichVu: [], selectedPhatSinh: [],
    Event: class {}, _renderSummaryTables() {}
});
vm.runInContext(source.slice(start, end), context);
const fields = Object.fromEntries(['JsonBanTiec','JsonThucUong','JsonDichVu','JsonPhatSinh'].map(name => [name,{value:'',dispatchEvent(){}}]));
const modal = {querySelector(s){return fields[s.match(/name="([^"]+)/)[1]];}};
context._writeInputs(modal);
assert.deepEqual(JSON.parse(fields.JsonBanTiec.value).map(x => [x.Mahang,x.IsChay]), [['M1',0],['C1',1]]);
context.selectedFoodsMan = [];
context._writeInputs(modal);
assert.deepEqual(JSON.parse(fields.JsonBanTiec.value).map(x => x.IsChay), [1]);
context.selectedFoodsChay = [];
context._writeInputs(modal);
assert.equal(fields.JsonBanTiec.value, '[]');
console.log('PASS mixed/vegetarian/empty menu save payload');
