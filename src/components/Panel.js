import React, { useContext } from 'react';
import { UserContext } from './UserContext';

const Panel = () => {
    const { user } = useContext(UserContext);

    return (
        <div className='panel'>
            <div className='user-info'>
                {user.avatar && <img src={user.avatar} alt='Avatar' className='user-avatar' />}
                <h1>Bienvenido, {user.fullName}</h1>
            </div>
            <style jsx>{`\n                .user-info {\n                    display: flex;\n                    align-items: center;\n                    justify-content: flex-end;\n                }\n                .user-avatar {\n                    border-radius: 50%;\n                    width: 50px;\n                    height: 50px;\n                    margin-right: 10px;\n                }\n            `}</style>
        </div>
    );
};

export default Panel;