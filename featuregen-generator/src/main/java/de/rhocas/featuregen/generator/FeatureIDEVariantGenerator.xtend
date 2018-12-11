////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
// MIT License                                                                    //
//                                                                                //
// Copyright (c) 2018 Nils Christian Ehmke                                        //
//                                                                                //
// Permission is hereby granted, free of charge, to any person obtaining a copy   //
// of this software and associated documentation files (the "Software"), to deal  //
// in the Software without restriction, including without limitation the rights   //
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
// copies of the Software, and to permit persons to whom the Software is          //
// furnished to do so, subject to the following conditions:                       //
//                                                                                //
// The above copyright notice and this permission notice shall be included in all //
// copies or substantial portions of the Software.                                //
//                                                                                //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  //
// SOFTWARE.                                                                      //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

package de.rhocas.featuregen.generator

/**
 * This class generates the variant from a FeatureIDE configuration file.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
final class FeatureIDEVariantGenerator {
	
	/**
	 * The main entry point of the standalone generator.
	 * 
	 * @param args
	 * 		The command line arguments. See {@link #generate(String[])} for details.
	 * 
	 * @since 1.1.0
	 */
	def static void main(String[] args) {
		val generator = new FeatureIDEVariantGenerator()
		generator.generate(args)
	}

	/**
	 * This method performs the actual generation.
	 * 
	 * @param args
	 * 		The arguments for the generator. This array must contain at least three entries. The arguments are as following:
	 *      <ul>
	 *      	<li>The path to the FeatureIDE configuration model file.</li>
	 *          <li>The path to the output folder.</li>
	 *          <li>The full qualified class name of the newly generated variant.</li>
	 *          <li>The optional prefix prepended to each feature.</li>
	 *          <li>The optional suffix appended to each feature. If this parameter is not given, {@code _FEATURE} will be used instead.</li>
	 *      </ul>
	 * 
	 * @throws IllegalArgumentException
	 * 		If the number of arguments is invalid or if the model file can not be found.		
	 * 
	 * @since 1.1.0
	 */
	def void generate(String[] args) {
	}
	
}