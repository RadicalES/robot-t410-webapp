import { useState } from 'react';

const useFormData = (initialValues) => {
    const [values, setValues] = useState(initialValues);

    const handleChange = ({name, value}) => {

        console.log("Set values: " + name + " value = " + value)

        setValues({...values, [name]: value });
    }

    // const handleInputChange = (event) => {
    //     const { name, value } = event.target;
    //     setValues({ ...values, [name]: value });
    // }

    return [ values, setValues, handleChange ];
}

export default useFormData;

