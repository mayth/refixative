interface JQuery
{
	formatNumber(options: Object, writeBack: bool, giveReturnValue: bool): string;

	parseNumber(options: Object, writeBack: bool, giveReturnValue: bool): number;
}

interface JQueryStatic
{
	formatNumber(numberString: string, options: Object): string;
	_formatNumber(number: number, options: Object, suffix: string, prefix: string, negativeInFront: bool): string;

	parseNumber(numberString: string, options: Object): number;
	_roundNumber(number: number, decimalPlaces: number): string;
}