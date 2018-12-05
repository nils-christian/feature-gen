package de.rhocas.featuregen.ap

import com.google.inject.Inject
import java.io.IOException
import java.util.Map
import org.eclipse.xtend.core.XtendInjectorSingleton
import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.eclipse.xtext.xbase.testing.CompilationTestHelper
import org.eclipse.xtext.util.IAcceptor
import org.eclipse.xtext.xbase.testing.CompilationTestHelper.Result

final class WorkspaceAwareXtendCompilerTester extends XtendCompilerTester {

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
