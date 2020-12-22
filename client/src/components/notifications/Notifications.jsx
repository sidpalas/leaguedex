import React, { useState, useRef } from "react";
import useOnclickOutside from "react-cool-onclickoutside";
import { Button } from "../../GlobalStyles";
import * as SC from "./Notifications.styles";
import Notification from "./components/notification/Notification";

const Notifications = () => {
  const [show, setShow] = useState(true);
  const [choices, setChoices] = useState({});
  const containerRef = useRef(null);

  const ref = useOnclickOutside(() => {
    setShow(false);
  });

  function handleChoice(id, confirmed) {
    setChoices((curr) => ({
      ...curr,
      [id]: confirmed,
    }));
  }

  const count = 2;

  return (
    <SC.Container ref={ref}>
      <SC.IconWrapper onClick={() => setShow((curr) => !curr)}>
        <SC.Icon />
        {count > 0 && <SC.Bubble>{count}</SC.Bubble>}
      </SC.IconWrapper>
      <SC.Wrapper show={show}>
        <SC.Heading>Unconfirmed matches</SC.Heading>
        <SC.Dropdown>
          <Notification
            handleChoice={handleChoice}
            choices={choices}
            id={1}
            lane="top"
            win={true}
            championA="Akali"
            championB="Renekton"
          />
        </SC.Dropdown>
        <SC.Footer>
          <Button logout style={{ width: "100%", marginLeft: "0" }}>
            Confirm
          </Button>
        </SC.Footer>
      </SC.Wrapper>
    </SC.Container>
  );
};

export default Notifications;
