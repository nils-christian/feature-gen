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

import org.eclipse.xtend.lib.macro.Active
import java.lang.annotation.Retention
import java.lang.annotation.Target

/**
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
@Target(TYPE)
@Retention(CLASS)
@Active(FeatureIDEVariantProcessor)
annotation FeatureIDEVariant {
	
	/**
	 * The path to a variant configuration file from the {@code FeatureIDE} containing a set of features. The file path is usually relative to the annotated
	 * class. If the file path starts with a slash ({@code /}), the file path is assumed to be relative to the project source folder. If this value is not
	 * given at all, it is assumed that the configuration model is contained in an xml file next to the annotated class with the same name as the annotated
	 * class.<br/>
	 * <br/>
	 * Please note: Due to restrictions of the active annotations, the file <b>must</b> be contained in the same project and the same source folder
	 * as the annotated class. Otherwise a build with various build tools might fail.
	 * 
	 * @since 1.0.0
	 */
	String value = ''
	
	/**
	 * The class which is annotated with {@link FeatureIDEFeatures}.
	 * 
	 * @since 1.0.0
	 */
	Class<?> featuresClass
	
}