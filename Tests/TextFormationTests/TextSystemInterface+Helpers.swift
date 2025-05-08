import Foundation

import TextFormation

extension TextSystemInterface where TextRange == NSRange {
	func runFilter<F: NewFilter<Self>>(_ filter: inout F, range: TextRange, string: String) throws -> Output? {
		let mutation = NewTextMutation(range: range, interface: self, string: string)
		
		if let output = try filter.processMutation(mutation) {
			return output
		}
		
		return try applyMutation(range, string: string)
	}

	func runFilter<F: NewFilter<Self>, R: RangeExpression>(
		_ filter: inout F,
		_ range: R,
		_ string: String
	) throws -> Output? where R.Bound == Int {
		try runFilter(&filter, range: NSRange(range), string: string)
	}
}
