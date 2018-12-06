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

package de.rhocas.featuregen.featureide.model.configuration;

import static org.hamcrest.collection.IsCollectionWithSize.hasSize;
import static org.hamcrest.collection.IsIterableContainingInOrder.contains;
import static org.hamcrest.core.Is.is;
import static org.hamcrest.core.IsInstanceOf.instanceOf;
import static org.junit.Assert.assertThat;

import java.util.List;
import java.util.stream.Collectors;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.junit.Test;
import org.xml.sax.SAXException;

/**
 * A simple unit test that makes sure that both the configuration model is parsable with the XSD classes.
 *
 * @author Nils Christian Ehmke
 */
public final class ConfigurationModelTest {
  
	@Test
	public void configurationModelFileShouldBeParsable() throws JAXBException, SAXException {
		final Unmarshaller unmarshaller = createUnmarshaller( );

		final Object object = unmarshaller.unmarshal( getClass( ).getResource( "/configuration.xml" ) );
		assertThat( object, is( instanceOf( Configuration.class ) ) );

		final Configuration configuration = ( Configuration ) object;
		assertThat(configuration.feature, hasSize(8));
		
		List<String> featureNames = configuration.feature.stream().map(Feature::getName).collect(Collectors.toList());
		assertThat(featureNames, contains("Root", "F1", "F2", "F3", "F3.1", "F4", "F4.1", "F4.2"));
	} 
	 
	private Unmarshaller createUnmarshaller() throws JAXBException, SAXException {
		final JAXBContext jaxbContext = JAXBContext.newInstance( ObjectFactory.class );
		final Unmarshaller unmarshaller = jaxbContext.createUnmarshaller( );

		final SchemaFactory schemaFactory = SchemaFactory.newInstance( XMLConstants.W3C_XML_SCHEMA_NS_URI );
		final Schema schema = schemaFactory.newSchema( getClass( ).getResource( "/configuration.xsd" ) );
		unmarshaller.setSchema( schema );

		return unmarshaller;
	}
	
}
