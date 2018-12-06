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

import com.google.inject.Inject
import java.io.IOException
import java.util.Map
import org.eclipse.xtend.core.XtendInjectorSingleton
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.util.IAcceptor
import org.eclipse.xtext.xbase.testing.CompilationTestHelper.Result

/**
 * This is a helper class to test the compilation results.
 * 
 * @author Nils Christian Ehmke
 */
package final class WorkspaceAwareXtendCompilerTester extends XtendCompilerTester {

	@Inject CompilationTestHelper compilationTestHelper

	def void assertCompilesTo(Map<String, String> workspaceContent, CharSequence source, CharSequence expected) {
		try {
			compilationTestHelper.configureFreshWorkspace()
			workspaceContent.forEach[k, v|compilationTestHelper.copyToWorkspace(k, v)]

			compilationTestHelper.assertCompilesTo(source, expected)
		} catch (IOException e) {
			Exceptions.sneakyThrow(e)
		}
	} 
	
	def void compile(Map<String, String> workspaceContent, CharSequence source, IAcceptor<Result> acceptor) {
		try {
			compilationTestHelper.configureFreshWorkspace()
			workspaceContent.forEach[k, v|compilationTestHelper.copyToWorkspace(k, v)]

			compilationTestHelper.compile(source, acceptor)
		} catch (IOException e) {
			Exceptions.sneakyThrow(e)
		}
	} 
	

	def static newWorkspaceAwareXtendCompilerTester(ClassLoader classLoader) {
		val workspaceAwareXtendCompilerTester = XtendInjectorSingleton.INJECTOR.getInstance(WorkspaceAwareXtendCompilerTester)
		workspaceAwareXtendCompilerTester.compilationTestHelper.javaCompilerClassPath = classLoader
		return workspaceAwareXtendCompilerTester
	}

}
