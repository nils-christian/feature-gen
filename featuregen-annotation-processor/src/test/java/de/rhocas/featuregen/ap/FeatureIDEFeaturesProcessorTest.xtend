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
 * A simple unit test for {@link FeatureIDEFeaturesProcessor}.
 *
 * @author Nils Christian Ehmke
 */
final class FeatureIDEFeaturesProcessorTest {

	extension WorkspaceAwareXtendCompilerTester = WorkspaceAwareXtendCompilerTester.newWorkspaceAwareXtendCompilerTester(FeatureIDEFeatures.classLoader)

	@Test
	def void simpleCaseShouldBeGeneratedCorrectly() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
					</and>
			    </struct>
			</featureModel>
		'''}

		assertCompilesTo(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/test/Features.java
			
			package test;
			
			import de.rhocas.featuregen.ap.FeatureIDEFeatures;
			
			@FeatureIDEFeatures
			@SuppressWarnings("all")
			public final class Features {
			}
			
			File 2 : /myProject/xtend-gen/test/RootFeature.java
			
			package test;
			
			/**
			 * This enumeration contains all available features.<br/>
			 * <br/>
			 * This enumeration is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public enum RootFeature {
			  ROOT_FEATURE,
			  
			  F1_FEATURE;
			}
			
			File 3 : /myProject/xtend-gen/test/RootFeatureCheckService.java
			
			package test;
			
			import java.util.Arrays;
			import java.util.Collections;
			import java.util.EnumSet;
			import java.util.List;
			import java.util.Objects;
			import java.util.Set;
			import test.RootFeature;
			import test.RootSelectedFeatures;
			import test.RootVariant;
			
			/**
			 * This service allows to check which features are currently active.<br/>
			 * <br/>
			 * Note that instances of this class are immutable and thus inherent thread safe.<br/>
			 * <br/>
			 * This service is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public final class RootFeatureCheckService {
			  private final Set activeFeatures;
			  
			  private final String description;
			  
			  private RootFeatureCheckService(final List<RootFeature> selectedFeatures, final String variantName) {
			    activeFeatures = EnumSet.noneOf( RootFeature.class );
			    activeFeatures.addAll( selectedFeatures );
			    
			    description = "RootFeatureCheckService [" + variantName + "]";
			  }
			  
			  /**
			   * Checks whether the given feature is currently active or not.
			   * 
			   * @param feature
			   * 	The feature to check. Must not be {@code null}.
			   * 	
			   * @return true if and only if the given feature is active.
			   * 
			   * @throws NullPointerException
			   * 	If the given feature is {@code null}.
			   * 
			   */
			  public boolean isFeatureActive(final RootFeature feature) {
			    Objects.requireNonNull( feature, "The feature must not be null." );
			    
			    return activeFeatures.contains( feature );
			  }
			  
			  @Override
			  public String toString() {
			    return description;
			  }
			  
			  /**
			   * Creates a new instance of this service with the features of the given variant.
			   * 
			   * @param variant
			   * 	The new variant. Must not be {@code null} and must be annotated with {@link RootSelectedFeatures}.
			   * 
			   * @return A new feature check service.
			   * 	
			   * @throws NullPointerException
			   * 	If the given variant is {@code null} or not annotated with {@link RootSelectedFeatures}.
			   * 
			   */
			  public static RootFeatureCheckService of(final Class<? extends RootVariant> variant) {
			    Objects.requireNonNull( variant, "The variant must not be null." );
			    
			    final RootSelectedFeatures selectedFeaturesAnnotation = variant.getAnnotation( RootSelectedFeatures.class );
			    Objects.requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with RootSelectedFeatures." );
			    final List<RootFeature> selectedFeatures = Arrays.asList( selectedFeaturesAnnotation.value( ) );
			    
			    return new RootFeatureCheckService( selectedFeatures, variant.getSimpleName( ) );
			  }
			  
			  /**
			   * Creates a new instance of this service without any active features.
			   * 
			   * @return A new feature check service.
			   * 
			   */
			  public static RootFeatureCheckService empty() {
			    return new RootFeatureCheckService( Collections.emptyList( ), "Empty" );
			  }
			}
			
			File 4 : /myProject/xtend-gen/test/RootSelectedFeatures.java
			
			package test;
			
			import java.lang.annotation.ElementType;
			import java.lang.annotation.Retention;
			import java.lang.annotation.RetentionPolicy;
			import java.lang.annotation.Target;
			import test.RootFeature;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br/>
			 * <br/>
			 * This annotation is generated.
			 * 
			 */
			@Retention(value = RetentionPolicy.RUNTIME)
			@Target(value = ElementType.TYPE)
			public @interface RootSelectedFeatures {
			  /**
			   * The selected features.
			   */
			  public RootFeature[] value();
			}
			
			File 5 : /myProject/xtend-gen/test/RootVariant.java
			
			package test;
			
			/**
			 * This is a marker interface for all variants.<br/>
			 * <br/>
			 * This interface is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public interface RootVariant {
			}
			
		''')
	}
	
	@Test
	def void extendedModelShouldBeGeneratedCorrectly() {
		val workspaceContent = #{'/myProject/src/model.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<extendedFeatureModel>
			    <properties/>
			    <struct>
			        <and abstract="true" mandatory="true" name="Root">
			            <and name="F1">
			                <attribute name="Attribute0" type="boolean" unit="" value="true"/>
			                <and mandatory="true" name="F2">
			                    <feature name="F2.1"/>
			                    <feature name="F2.2"/>
			                </and>
			                <or name="F3">
			                    <feature name="F3.1"/>
			                    <feature name="F3.2"/>
			                </or>
			                <alt name="F4">
			                    <feature name="F4.1"/>
			                    <feature name="F4.2"/>
			                </alt>
			                <and name="F5">
			                    <feature name="F5.1"/>
			                    <feature name="F5.2"/>
			                </and>
			            </and>
			        </and>
			    </struct>
			    <constraints>
			        <rule>
			            <description>
			Abc
			</description>
			            <eq>
			                <disj>
			                    <var>F4</var>
			                    <disj>
			                        <var>F3</var>
			                        <var>F1</var>
			                    </disj>
			                </disj>
			                <disj>
			                    <var>F3</var>
			                    <disj>
			                        <var>F4</var>
			                        <var>F3</var>
			                    </disj>
			                </disj>
			            </eq>
			        </rule>
			    </constraints>
			    <calculations Auto="true" Constraints="true" Features="true" Redundant="true" Tautology="true"/>
			    <comments/>
			    <featureOrder userDefined="true">
			        <feature name="F1"/>
			        <feature name="F2"/>
			        <feature name="F2.1"/>
			        <feature name="F3"/>
			        <feature name="F3.1"/>
			        <feature name="F3.2"/>
			        <feature name="F2.2"/>
			        <feature name="F4"/>
			        <feature name="F4.1"/>
			        <feature name="F4.2"/>
			    </featureOrder>
			</extendedFeatureModel>
		'''}
		
		assertCompilesTo(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/test/Features.java
			
			package test;
			
			import de.rhocas.featuregen.ap.FeatureIDEFeatures;
			
			@FeatureIDEFeatures
			@SuppressWarnings("all")
			public final class Features {
			}
			
			File 2 : /myProject/xtend-gen/test/RootFeature.java
			
			package test;
			
			/**
			 * This enumeration contains all available features.<br/>
			 * <br/>
			 * This enumeration is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public enum RootFeature {
			  F1_FEATURE,
			  
			  F2_FEATURE,
			  
			  F21_FEATURE,
			  
			  F22_FEATURE,
			  
			  F3_FEATURE,
			  
			  F31_FEATURE,
			  
			  F32_FEATURE,
			  
			  F4_FEATURE,
			  
			  F41_FEATURE,
			  
			  F42_FEATURE,
			  
			  F5_FEATURE,
			  
			  F51_FEATURE,
			  
			  F52_FEATURE;
			}
			
			File 3 : /myProject/xtend-gen/test/RootFeatureCheckService.java
			
			package test;
			
			import java.util.Arrays;
			import java.util.Collections;
			import java.util.EnumSet;
			import java.util.List;
			import java.util.Objects;
			import java.util.Set;
			import test.RootFeature;
			import test.RootSelectedFeatures;
			import test.RootVariant;
			
			/**
			 * This service allows to check which features are currently active.<br/>
			 * <br/>
			 * Note that instances of this class are immutable and thus inherent thread safe.<br/>
			 * <br/>
			 * This service is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public final class RootFeatureCheckService {
			  private final Set activeFeatures;
			  
			  private final String description;
			  
			  private RootFeatureCheckService(final List<RootFeature> selectedFeatures, final String variantName) {
			    activeFeatures = EnumSet.noneOf( RootFeature.class );
			    activeFeatures.addAll( selectedFeatures );
			    
			    description = "RootFeatureCheckService [" + variantName + "]";
			  }
			  
			  /**
			   * Checks whether the given feature is currently active or not.
			   * 
			   * @param feature
			   * 	The feature to check. Must not be {@code null}.
			   * 	
			   * @return true if and only if the given feature is active.
			   * 
			   * @throws NullPointerException
			   * 	If the given feature is {@code null}.
			   * 
			   */
			  public boolean isFeatureActive(final RootFeature feature) {
			    Objects.requireNonNull( feature, "The feature must not be null." );
			    
			    return activeFeatures.contains( feature );
			  }
			  
			  @Override
			  public String toString() {
			    return description;
			  }
			  
			  /**
			   * Creates a new instance of this service with the features of the given variant.
			   * 
			   * @param variant
			   * 	The new variant. Must not be {@code null} and must be annotated with {@link RootSelectedFeatures}.
			   * 
			   * @return A new feature check service.
			   * 	
			   * @throws NullPointerException
			   * 	If the given variant is {@code null} or not annotated with {@link RootSelectedFeatures}.
			   * 
			   */
			  public static RootFeatureCheckService of(final Class<? extends RootVariant> variant) {
			    Objects.requireNonNull( variant, "The variant must not be null." );
			    
			    final RootSelectedFeatures selectedFeaturesAnnotation = variant.getAnnotation( RootSelectedFeatures.class );
			    Objects.requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with RootSelectedFeatures." );
			    final List<RootFeature> selectedFeatures = Arrays.asList( selectedFeaturesAnnotation.value( ) );
			    
			    return new RootFeatureCheckService( selectedFeatures, variant.getSimpleName( ) );
			  }
			  
			  /**
			   * Creates a new instance of this service without any active features.
			   * 
			   * @return A new feature check service.
			   * 
			   */
			  public static RootFeatureCheckService empty() {
			    return new RootFeatureCheckService( Collections.emptyList( ), "Empty" );
			  }
			}
			
			File 4 : /myProject/xtend-gen/test/RootSelectedFeatures.java
			
			package test;
			
			import java.lang.annotation.ElementType;
			import java.lang.annotation.Retention;
			import java.lang.annotation.RetentionPolicy;
			import java.lang.annotation.Target;
			import test.RootFeature;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br/>
			 * <br/>
			 * This annotation is generated.
			 * 
			 */
			@Retention(value = RetentionPolicy.RUNTIME)
			@Target(value = ElementType.TYPE)
			public @interface RootSelectedFeatures {
			  /**
			   * The selected features.
			   */
			  public RootFeature[] value();
			}
			
			File 5 : /myProject/xtend-gen/test/RootVariant.java
			
			package test;
			
			/**
			 * This is a marker interface for all variants.<br/>
			 * <br/>
			 * This interface is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public interface RootVariant {
			}
			
		''')
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
					</and>
			    </struct>
			</featureModel>
		'''}

		assertCompilesTo(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»(prefix='prefix_', suffix='_suffix')
			class Features {   
			}
		''', '''
			MULTIPLE FILES WERE GENERATED
			
			File 1 : /myProject/xtend-gen/test/Features.java
			
			package test;
			
			import de.rhocas.featuregen.ap.FeatureIDEFeatures;
			
			@FeatureIDEFeatures(prefix = "prefix_", suffix = "_suffix")
			@SuppressWarnings("all")
			public final class Features {
			}
			
			File 2 : /myProject/xtend-gen/test/RootFeature.java
			
			package test;
			
			/**
			 * This enumeration contains all available features.<br/>
			 * <br/>
			 * This enumeration is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public enum RootFeature {
			  PREFIX_ROOT_SUFFIX,
			  
			  PREFIX_F1_SUFFIX;
			}
			
			File 3 : /myProject/xtend-gen/test/RootFeatureCheckService.java
			
			package test;
			
			import java.util.Arrays;
			import java.util.Collections;
			import java.util.EnumSet;
			import java.util.List;
			import java.util.Objects;
			import java.util.Set;
			import test.RootFeature;
			import test.RootSelectedFeatures;
			import test.RootVariant;
			
			/**
			 * This service allows to check which features are currently active.<br/>
			 * <br/>
			 * Note that instances of this class are immutable and thus inherent thread safe.<br/>
			 * <br/>
			 * This service is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public final class RootFeatureCheckService {
			  private final Set activeFeatures;
			  
			  private final String description;
			  
			  private RootFeatureCheckService(final List<RootFeature> selectedFeatures, final String variantName) {
			    activeFeatures = EnumSet.noneOf( RootFeature.class );
			    activeFeatures.addAll( selectedFeatures );
			    
			    description = "RootFeatureCheckService [" + variantName + "]";
			  }
			  
			  /**
			   * Checks whether the given feature is currently active or not.
			   * 
			   * @param feature
			   * 	The feature to check. Must not be {@code null}.
			   * 	
			   * @return true if and only if the given feature is active.
			   * 
			   * @throws NullPointerException
			   * 	If the given feature is {@code null}.
			   * 
			   */
			  public boolean isFeatureActive(final RootFeature feature) {
			    Objects.requireNonNull( feature, "The feature must not be null." );
			    
			    return activeFeatures.contains( feature );
			  }
			  
			  @Override
			  public String toString() {
			    return description;
			  }
			  
			  /**
			   * Creates a new instance of this service with the features of the given variant.
			   * 
			   * @param variant
			   * 	The new variant. Must not be {@code null} and must be annotated with {@link RootSelectedFeatures}.
			   * 
			   * @return A new feature check service.
			   * 	
			   * @throws NullPointerException
			   * 	If the given variant is {@code null} or not annotated with {@link RootSelectedFeatures}.
			   * 
			   */
			  public static RootFeatureCheckService of(final Class<? extends RootVariant> variant) {
			    Objects.requireNonNull( variant, "The variant must not be null." );
			    
			    final RootSelectedFeatures selectedFeaturesAnnotation = variant.getAnnotation( RootSelectedFeatures.class );
			    Objects.requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with RootSelectedFeatures." );
			    final List<RootFeature> selectedFeatures = Arrays.asList( selectedFeaturesAnnotation.value( ) );
			    
			    return new RootFeatureCheckService( selectedFeatures, variant.getSimpleName( ) );
			  }
			  
			  /**
			   * Creates a new instance of this service without any active features.
			   * 
			   * @return A new feature check service.
			   * 
			   */
			  public static RootFeatureCheckService empty() {
			    return new RootFeatureCheckService( Collections.emptyList( ), "Empty" );
			  }
			}
			
			File 4 : /myProject/xtend-gen/test/RootSelectedFeatures.java
			
			package test;
			
			import java.lang.annotation.ElementType;
			import java.lang.annotation.Retention;
			import java.lang.annotation.RetentionPolicy;
			import java.lang.annotation.Target;
			import test.RootFeature;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br/>
			 * <br/>
			 * This annotation is generated.
			 * 
			 */
			@Retention(value = RetentionPolicy.RUNTIME)
			@Target(value = ElementType.TYPE)
			public @interface RootSelectedFeatures {
			  /**
			   * The selected features.
			   */
			  public RootFeature[] value();
			}
			
			File 5 : /myProject/xtend-gen/test/RootVariant.java
			
			package test;
			
			/**
			 * This is a marker interface for all variants.<br/>
			 * <br/>
			 * This interface is generated.
			 * 
			 */
			@SuppressWarnings("all")
			public interface RootVariant {
			}
			
		''')
	}
	
	@Test
	def void missingFileShouldResultInError() {
		compile(#{}, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»
			class Features {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, hasSize(1))
			
			val error = result.errorsAndWarnings.head
			assertThat(error.severity, is(Severity.ERROR))
			assertThat(error.message, is('The model file could not be found (Assumed path was: \'/myProject/src/model.xml\').'))
		])
	}
	
	@Test
	def void filePathWithoutSlashShouldBeRelativeToClass() {
		val workspaceContent = #{'/myProject/src/path/file.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
					</and>
			    </struct>
			</featureModel>
		'''}
		
		compile(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»('path/file.xml')
			class Features {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, is(empty()))
		])
	}
	
	@Test
	def void filePathWithSlashShouldBeRelativeToSourceFolder() {
		val workspaceContent = #{'/myProject/path/file.xml' -> '''
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<featureModel>
			    <properties/>
			    <struct>
			    	<and mandatory="true" name="Root">
						<feature name="F1"/>
					</and>
			    </struct>
			</featureModel>
		'''}
		
		compile(workspaceContent, '''
			package test
			
			import «FeatureIDEFeatures.name»
			
			@«FeatureIDEFeatures.simpleName»('/path/file.xml')
			class Features {   
			}
		''', [result |
			assertThat(result.errorsAndWarnings, is(empty()))
		])
	}
	
}
