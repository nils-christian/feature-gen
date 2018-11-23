package de.rhocas.featuregen.featureide.feature.model;

import static org.hamcrest.collection.IsCollectionWithSize.hasSize;
import static org.hamcrest.core.Is.is;
import static org.hamcrest.core.IsInstanceOf.instanceOf;
import static org.hamcrest.core.IsNull.notNullValue;
import static org.junit.Assert.assertThat;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.junit.Test;
import org.xml.sax.SAXException;

import de.rhocas.featuregen.featureide.model.feature.BranchedFeatureType;
import de.rhocas.featuregen.featureide.model.feature.FeatureModelType;
import de.rhocas.featuregen.featureide.model.feature.ObjectFactory;
import de.rhocas.featuregen.featureide.model.feature.StructType;

/**
 * A simple unit test that makes sure that both the feature model and the extended feature model are parsable with the XSD classes.
 *
 * @author Nils Christian Ehmke
 */
public final class FeatureModelTest {

	@Test
	public void featureModelFileShouldBeParsable( ) throws JAXBException, SAXException {
		final Unmarshaller unmarshaller = createUnmarshaller( );

		final Object object = unmarshaller.unmarshal( getClass( ).getResource( "/featureModel.xml" ) );
		assertThat( object, is( instanceOf( FeatureModelType.class ) ) );

		final FeatureModelType featureModelType = ( FeatureModelType ) object;
		final StructType struct = featureModelType.getStruct( );
		assertThat( struct, is( notNullValue( ) ) );

		assertThat( struct.getAnd( ).getName( ), is( "Root" ) );
		final BranchedFeatureType branchedFeature = ( BranchedFeatureType ) struct.getAnd( ).getAndOrOrOrAlt( ).get( 0 ).getValue( );
		assertThat( branchedFeature.getAndOrOrOrAlt( ), hasSize( 4 ) );
	}

	@Test
	public void extendedFeatureModelFileShouldBeParsable( ) throws JAXBException, SAXException {
		final Unmarshaller unmarshaller = createUnmarshaller( );

		final Object object = unmarshaller.unmarshal( getClass( ).getResource( "/extendedFeatureModel.xml" ) );
		assertThat( object, is( instanceOf( FeatureModelType.class ) ) );

		final FeatureModelType featureModelType = ( FeatureModelType ) object;
		final StructType struct = featureModelType.getStruct( );
		assertThat( struct, is( notNullValue( ) ) );

		assertThat( struct.getAnd( ).getName( ), is( "Root" ) );
		final BranchedFeatureType branchedFeature = ( BranchedFeatureType ) struct.getAnd( ).getAndOrOrOrAlt( ).get( 0 ).getValue( );
		assertThat( branchedFeature.getAndOrOrOrAlt( ), hasSize( 4 ) );
	}

	private Unmarshaller createUnmarshaller( ) throws JAXBException, SAXException {
		final JAXBContext jaxbContext = JAXBContext.newInstance( ObjectFactory.class );
		final Unmarshaller unmarshaller = jaxbContext.createUnmarshaller( );

		final SchemaFactory schemaFactory = SchemaFactory.newInstance( XMLConstants.W3C_XML_SCHEMA_NS_URI );
		final Schema schema = schemaFactory.newSchema( getClass( ).getResource( "/feature.xsd" ) );
		unmarshaller.setSchema( schema );

		return unmarshaller;
	}
}
