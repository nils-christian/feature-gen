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

import org.junit.Test
import static org.hamcrest.collection.IsEmptyCollection.empty
import static org.hamcrest.collection.IsCollectionWithSize.hasSize
import static org.hamcrest.core.Is.is
import static org.junit.Assert.assertThat
import org.eclipse.xtext.diagnostics.Severity

/**
 * A simple unit test for {@link FeatureIDEVariantProcessorTest}.
 *
 * @author Nils Christian Ehmke
 */
final class FeatureIDEVariantProcessorTest {

	extension WorkspaceAwareXtendCompilerTester = WorkspaceAwareXtendCompilerTester.newWorkspaceAwareXtendCompilerTester(FeatureIDEVariant.classLoader)

	@Test
	def void simpleCaseShouldBeGeneratedCorrectly() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
						<feature name="F2"/>
					</and>
					  </struct>
			</featureModel>
		''', '/myProject/src/Variant.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="Root"/>
			    <feature automatic="selected" name="F1"/>
			    <feature automatic="selected" name="F3"/>
			</configuration>
		'''}

		compile(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			import «FeatureIDEVariant.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
			
			@«FeatureIDEVariant.simpleName»(featuresClass=Features)
			class Variant {   
			}
		''', [
			assertThat(errorsAndWarnings, is(empty()))

			assertThat(getGeneratedCode('test.Variant'), is('''
				package test;
				
				import de.rhocas.featuregen.ap.FeatureIDEVariant;
				import test.Features;
				import test.RootFeature;
				import test.RootSelectedFeatures;
				import test.RootVariant;
				
				@FeatureIDEVariant(featuresClass = Features.class)
				@RootSelectedFeatures(value = { RootFeature.ROOT_FEATURE, RootFeature.F1_FEATURE })
				@SuppressWarnings("all")
				public final class Variant implements RootVariant {
				}
			'''))
		])
	}
	
	@Test
	def void simpleCaseWithPrefixAndSuffixShouldBeGeneratedCorrectly() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
						<feature name="F2"/>
					</and>
					  </struct>
			</featureModel>
		''', '/myProject/src/Variant.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="Root"/>
			    <feature automatic="selected" name="F1"/>
			    <feature automatic="selected" name="F3"/>
			</configuration>
		'''}

		compile(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			import «FeatureIDEVariant.name»
			
			@«FeatureIDEFeatures.simpleName»(prefix='prefix_', suffix='_suffix')
			class Features {   
			}
			
			@«FeatureIDEVariant.simpleName»(featuresClass=Features)
			class Variant {   
			}
		''', [
			assertThat(errorsAndWarnings, is(empty()))

			assertThat(getGeneratedCode('test.Variant'), is('''
				package test;
				
				import de.rhocas.featuregen.ap.FeatureIDEVariant;
				import test.Features;
				import test.RootFeature;
				import test.RootSelectedFeatures;
				import test.RootVariant;
				
				@FeatureIDEVariant(featuresClass = Features.class)
				@RootSelectedFeatures(value = { RootFeature.PREFIX_ROOT_SUFFIX, RootFeature.PREFIX_F1_SUFFIX })
				@SuppressWarnings("all")
				public final class Variant implements RootVariant {
				}
			'''))
		])
	}
	
	@Test
	def void missingFileShouldResultInError() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
						<feature name="F2"/>
					</and>
					  </struct>
			</featureModel>
		'''}
		
		compile(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			import «FeatureIDEVariant.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
			
			@«FeatureIDEVariant.simpleName»(featuresClass=Features)
			class Variant {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, hasSize(1))
			
			val error = result.errorsAndWarnings.head
			assertThat(error.severity, is(Severity.ERROR))
			assertThat(error.message, is('The configuration file could not be found (Assumed path was: \'/myProject/src/Variant.xml\').'))
		])
	}
	
	@Test
	def void filePathWithoutSlashShouldBeRelativeToClass() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
						<feature name="F2"/>
					</and>
					  </struct>
			</featureModel>
		''', '/myProject/src/path/Variant.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="Root"/>
			    <feature automatic="selected" name="F1"/>
			    <feature automatic="selected" name="F3"/>
			</configuration>
		'''}

		compile(workspaceContent, '''
			package test
						
			import «FeatureIDEFeatures.name»
			import «FeatureIDEVariant.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
			
			@«FeatureIDEVariant.simpleName»(featuresClass=Features, value='path/Variant.xml')
			class Variant {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, is(empty()))
		])
	}
	
	@Test
	def void filePathWithSlashShouldBeRelativeToSourceFolder() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
						<feature name="F2"/>
					</and>
					  </struct>
			</featureModel>
		''', '/myProject/path/Variant.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<configuration>
			    <feature automatic="selected" name="Root"/>
			    <feature automatic="selected" name="F1"/>
			    <feature automatic="selected" name="F3"/>
			</configuration>
		'''}

		compile(workspaceContent, '''
			package test
						
			import «FeatureIDEFeatures.name»
			import «FeatureIDEVariant.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
			
			@«FeatureIDEVariant.simpleName»(featuresClass=Features, value='/path/Variant.xml')
			class Variant {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, is(empty()))
		])
	}
	
}
