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

package de.rhocas.featuregen.ap

import org.eclipse.xtend.lib.macro.declaration.Type

/**
 * This is a helper class to use consistent names between the annotation processors.
 * 
 * @author Nils Christian Ehmke
 */
package final class NameProvider {

	def String getFullQualifiedFeaturesEnumName(Type annotatedElement, String rootFeatureName) {
		'''«getFullQualifiedPrefix(annotatedElement, rootFeatureName)»Feature'''
	}

	def String getFullQualifiedFeatureCheckServiceClassName(Type annotatedElement, String rootFeatureName) {
		'''«getFullQualifiedPrefix(annotatedElement, rootFeatureName)»FeatureCheckService'''
	}

	def String getFullQualifiedSelectedFeaturesAnnotationName(Type annotatedElement, String rootFeatureName) {
		'''«getFullQualifiedPrefix(annotatedElement, rootFeatureName)»SelectedFeatures'''
	}

	def String getFullQualifiedVariantInterfaceName(Type annotatedElement, String rootFeatureName) {
		'''«getFullQualifiedPrefix(annotatedElement, rootFeatureName)»Variant'''
	}

	private def String getFullQualifiedPrefix(Type annotatedElement, String rootFeatureName) {
		// We cannot use the package of the compilation unit as this leads to wrong results in this case.
		val qualifiedName = annotatedElement.qualifiedName
		val simpleName = annotatedElement.simpleName
		val packageName = qualifiedName.substring(0, qualifiedName.length - simpleName.length - 1)
		
		'''«packageName».«rootFeatureName»'''
	}

}
